import Foundation

// MARK: - Interface

/// The protocol describing a manager to build CocoaPods project.
public protocol IBuildManager: AnyObject {
    /// Builds CocoaPods project and keeps binaries.
    /// - Parameters:
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - options: Xcode build options.
    ///   - paths: A collection of Xcode paths.
    ///   - ignoreCache: A flag to ignore already built binaries.
    func build(targetsRegex: NSRegularExpression?,
               exceptTargetsRegex: NSRegularExpression?,
               options: XcodeBuildOptions,
               paths: XcodeBuildPaths,
               ignoreCache: Bool) async throws
}

protocol IInternalBuildManager: IBuildManager {
    func prepare(targetsRegex: NSRegularExpression?,
                 exceptTargetsRegex: NSRegularExpression?,
                 freeSpaceIfNeeded: Bool,
                 patchLibraries: Bool) async throws -> TargetsMap
    func makeBuildTarget(_ targets: TargetsMap) async throws -> IInternalTarget
    func build(_ target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws
}

// MARK: - Implementation

final class BuildManager: Loggable {
    let logger: ILogger
    private let buildTargetsManager: BuildTargetsManager
    private let librariesPatcher: ILibrariesPatcher
    private let xcodeProject: IInternalXcodeProject
    private let rugbyXcodeProject: RugbyXcodeProject
    private let backupManager: IBackupManager
    private let processMonitor: IProcessMonitor
    private let xcodeBuild: XcodeBuild
    private let binariesManager: IBinariesStorage
    private let targetsHasher: TargetsHasher
    private let useBinariesManager: IUseBinariesManager
    private let binariesCleaner: BinariesCleaner
    private let environmentCollector: IEnvironmentCollector
    private let featureToggles: IFeatureToggles
    private let targetTreePainter: ITargetTreePainter

    init(logger: ILogger,
         buildTargetsManager: BuildTargetsManager,
         librariesPatcher: ILibrariesPatcher,
         xcodeProject: IInternalXcodeProject,
         rugbyXcodeProject: RugbyXcodeProject,
         backupManager: IBackupManager,
         processMonitor: IProcessMonitor,
         xcodeBuild: XcodeBuild,
         binariesManager: IBinariesStorage,
         targetsHasher: TargetsHasher,
         useBinariesManager: IUseBinariesManager,
         binariesCleaner: BinariesCleaner,
         environmentCollector: IEnvironmentCollector,
         featureToggles: IFeatureToggles,
         targetTreePainter: ITargetTreePainter) {
        self.logger = logger
        self.buildTargetsManager = buildTargetsManager
        self.librariesPatcher = librariesPatcher
        self.xcodeProject = xcodeProject
        self.rugbyXcodeProject = rugbyXcodeProject
        self.backupManager = backupManager
        self.processMonitor = processMonitor
        self.xcodeBuild = xcodeBuild
        self.binariesManager = binariesManager
        self.targetsHasher = targetsHasher
        self.useBinariesManager = useBinariesManager
        self.binariesCleaner = binariesCleaner
        self.environmentCollector = environmentCollector
        self.featureToggles = featureToggles
        self.targetTreePainter = targetTreePainter
    }

    private func reuseTargets(
        targets: TargetsMap,
        options: XcodeBuildOptions,
        paths _: XcodeBuildPaths,
        ignoreCache: Bool
    ) async throws -> TargetsMap? {
        try await log("Hashing Targets", auto: await targetsHasher.hash(targets, xcargs: options.xcargs))

        var shared: TargetsMap = [:]
        var buildTargets = targets
        if !ignoreCache {
            (shared, buildTargets) = try await log(
                "Finding Binaries",
                auto: binariesManager.findBinaries(ofTargets: buildTargets, buildOptions: options)
            )
        }
        guard buildTargets.isNotEmpty else {
            await log("Found 100% Binaries (\(targets.count))", level: .result)
            return nil
        }

        if featureToggles.printMissingBinaries {
            let tree = targetTreePainter.paint(targets: buildTargets)
            await logPlain(
                "\(".".yellow) \("Missing Binaries (\(buildTargets.count))".green)\n\(tree)"
            )
        }

        if shared.isNotEmpty {
            let percent = shared.count.percent(total: targets.count)
            await log("Found \(percent)% Binaries (\(shared.count)/\(targets.count))", level: .result)

            await log("Reusing Binaries: \n\(shared.values.map { "* \($0.name)" }.sorted().joined(separator: "\n"))",
                      level: .info)
            try await log("Reusing Binaries", auto: await useBinariesManager.use(targets: shared, keepGroups: true))

            try await log("Saving Project", auto: await xcodeProject.save())
            xcodeProject.resetCache()
        }
        return buildTargets
    }
}

extension BuildManager: IInternalBuildManager {
    func prepare(targetsRegex: NSRegularExpression?,
                 exceptTargetsRegex: NSRegularExpression?,
                 freeSpaceIfNeeded: Bool,
                 patchLibraries: Bool) async throws -> TargetsMap {
        try await environmentCollector.logXcodeVersion()
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let targets = try await log(
            "Finding Build Targets",
            auto: await buildTargetsManager.findTargets(targetsRegex, exceptTargets: exceptTargetsRegex)
        )
        guard targets.isNotEmpty else { throw BuildError.cantFindBuildTargets }

        try await log("Backuping", level: .info, auto: await backupManager.backup(xcodeProject, kind: .tmp))
        if freeSpaceIfNeeded {
            try await log("Checking Binaries Storage", auto: await binariesCleaner.freeSpace())
        }
        if patchLibraries {
            try await log("Patching Libraries", level: .info, auto: await librariesPatcher.patch(targets))
        }
        return targets
    }

    func makeBuildTarget(_ targets: TargetsMap) async throws -> IInternalTarget {
        let buildTarget = try await log("Creating Build Target",
                                        auto: await buildTargetsManager.createTarget(dependencies: targets))
        try await log("Saving Project", auto: await xcodeProject.save())
        return buildTarget
    }

    func build(_ target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws {
        let title = "\(options.config): \(options.sdk.string)-\(options.arch) (\(target.explicitDependencies.count))"
        await log(
            "\(title)\n\(target.explicitDependencies.values.map { "* \($0.name)" }.sorted().joined(separator: "\n"))",
            level: .info
        )

        try await log(title, metricKey: "xcodebuild", level: .result, block: { [weak self] in
            guard let self else { return }

            let cleanup = {
                try? self.backupManager.restore(.tmp)
                self.xcodeProject.resetCache()
            }
            let processInterruptionTask = processMonitor.runOnInterruption(cleanup)

            defer {
                processInterruptionTask.cancel()
                cleanup()
            }
            try self.xcodeBuild.build(target: target.name, options: options, paths: paths)
        })
    }
}

// MARK: - IBuildManager

extension BuildManager: IBuildManager {
    public func build(targetsRegex: NSRegularExpression?,
                      exceptTargetsRegex: NSRegularExpression?,
                      options: XcodeBuildOptions,
                      paths: XcodeBuildPaths,
                      ignoreCache: Bool) async throws {
        let targets = try await prepare(targetsRegex: targetsRegex,
                                        exceptTargetsRegex: exceptTargetsRegex,
                                        freeSpaceIfNeeded: true,
                                        patchLibraries: true)
        guard let buildTargets = try await reuseTargets(
            targets: targets,
            options: options,
            paths: paths,
            ignoreCache: ignoreCache
        ) else { return }

        let buildTarget = try await makeBuildTarget(buildTargets)
        try await build(buildTarget, options: options, paths: paths)

        try await log(
            "Saving binaries (\(buildTarget.explicitDependencies.count))",
            level: .result,
            auto: await binariesManager.saveBinaries(ofTargets: buildTarget.explicitDependencies,
                                                     buildOptions: options,
                                                     buildPaths: paths)
        )
    }
}
