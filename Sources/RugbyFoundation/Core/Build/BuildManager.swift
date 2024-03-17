import Foundation

// MARK: - Interface

/// The protocol describing a manager to build CocoaPods project.
public protocol IBuildManager: AnyObject {
    /// Builds CocoaPods project and keeps binaries.
    /// - Parameters:
    ///   - targetsOptions: A set of options to to select targets.
    ///   - options: Xcode build options.
    ///   - paths: A collection of Xcode paths.
    ///   - ignoreCache: A flag to ignore already built binaries.
    func build(targetsOptions: TargetsOptions,
               options: XcodeBuildOptions,
               paths: XcodeBuildPaths,
               ignoreCache: Bool) async throws
}

protocol IInternalBuildManager: IBuildManager {
    func prepare(targets: TargetsScope,
                 targetsTryMode: Bool,
                 freeSpaceIfNeeded: Bool,
                 patchLibraries: Bool) async throws -> TargetsMap
    func makeBuildTarget(_ targets: TargetsMap) async throws -> IInternalTarget
    func build(_ target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws
    func build(targets: TargetsScope,
               targetsTryMode: Bool,
               options: XcodeBuildOptions,
               paths: XcodeBuildPaths,
               ignoreCache: Bool) async throws
}

// MARK: - Implementation

final class BuildManager: Loggable {
    let logger: ILogger
    private let buildTargetsManager: IBuildTargetsManager
    private let librariesPatcher: ILibrariesPatcher
    private let xcodeProject: IInternalXcodeProject
    private let rugbyXcodeProject: IRugbyXcodeProject
    private let backupManager: IBackupManager
    private let processMonitor: IProcessMonitor
    private let xcodeBuild: IXcodeBuild
    private let binariesStorage: IBinariesStorage
    private let targetsHasher: ITargetsHasher
    private let useBinariesManager: IUseBinariesManager
    private let binariesCleaner: IBinariesCleaner
    private let environmentCollector: IEnvironmentCollector
    private let env: IEnvironment
    private let targetTreePainter: ITargetTreePainter
    private let targetsPrinter: ITargetsPrinter

    init(logger: ILogger,
         buildTargetsManager: IBuildTargetsManager,
         librariesPatcher: ILibrariesPatcher,
         xcodeProject: IInternalXcodeProject,
         rugbyXcodeProject: IRugbyXcodeProject,
         backupManager: IBackupManager,
         processMonitor: IProcessMonitor,
         xcodeBuild: IXcodeBuild,
         binariesStorage: IBinariesStorage,
         targetsHasher: ITargetsHasher,
         useBinariesManager: IUseBinariesManager,
         binariesCleaner: IBinariesCleaner,
         environmentCollector: IEnvironmentCollector,
         env: IEnvironment,
         targetTreePainter: ITargetTreePainter,
         targetsPrinter: ITargetsPrinter) {
        self.logger = logger
        self.buildTargetsManager = buildTargetsManager
        self.librariesPatcher = librariesPatcher
        self.xcodeProject = xcodeProject
        self.rugbyXcodeProject = rugbyXcodeProject
        self.backupManager = backupManager
        self.processMonitor = processMonitor
        self.xcodeBuild = xcodeBuild
        self.binariesStorage = binariesStorage
        self.targetsHasher = targetsHasher
        self.useBinariesManager = useBinariesManager
        self.binariesCleaner = binariesCleaner
        self.environmentCollector = environmentCollector
        self.env = env
        self.targetTreePainter = targetTreePainter
        self.targetsPrinter = targetsPrinter
    }

    private func reuseTargets(
        targets: TargetsMap,
        options: XcodeBuildOptions,
        ignoreCache: Bool
    ) async throws -> TargetsMap? {
        try await log("Hashing Targets", auto: await targetsHasher.hash(targets, xcargs: options.xcargs))

        var shared: TargetsMap = [:]
        var buildTargets = targets
        if !ignoreCache {
            (shared, buildTargets) = try await log(
                "Finding Binaries",
                auto: binariesStorage.findBinaries(ofTargets: buildTargets, buildOptions: options)
            )
        }
        guard buildTargets.isNotEmpty else {
            await log("Found 100% Binaries (\(targets.count))", level: .result)
            return nil
        }

        if env.printMissingBinaries {
            let tree = targetTreePainter.paint(targets: buildTargets)
            await logPlain(
                "\(".".yellow) \("Missing Binaries (\(buildTargets.count))".green)\n\(tree)"
            )
        }

        if shared.isNotEmpty {
            let percent = shared.count.percent(total: targets.count)
            await log("Found \(percent)% Binaries (\(shared.count)/\(targets.count))", level: .result)

            await log("Reusing Binaries:\n\(shared.values.map { "* \($0.name)" }.sorted().joined(separator: "\n"))",
                      level: .info)
            try await log("Reusing Binaries", auto: await useBinariesManager.use(targets: shared, keepGroups: true))

            try await log("Saving Project", auto: await xcodeProject.save())
            xcodeProject.resetCache()
        }
        return buildTargets
    }
}

extension BuildManager: IInternalBuildManager {
    func prepare(targets: TargetsScope,
                 targetsTryMode: Bool,
                 freeSpaceIfNeeded: Bool,
                 patchLibraries: Bool) async throws -> TargetsMap {
        let exactTargets: TargetsMap
        switch targets {
        case let .exact(targets):
            exactTargets = buildTargetsManager.filterTargets(targets)
        case let .filter(regex, exceptRegex):
            exactTargets = try await log(
                "Finding Build Targets",
                auto: await buildTargetsManager.findTargets(regex, exceptTargets: exceptRegex)
            )
        }
        if targetsTryMode { return exactTargets }
        guard exactTargets.isNotEmpty else { throw BuildError.cantFindBuildTargets }

        try await log("Backuping", auto: await backupManager.backup(xcodeProject, kind: .tmp))
        if freeSpaceIfNeeded {
            try await log("Checking Binaries Storage", auto: await binariesCleaner.freeSpace())
        }
        if patchLibraries {
            try await log("Patching Libraries", auto: await librariesPatcher.patch(exactTargets))
        }
        return exactTargets
    }

    func makeBuildTarget(_ targets: TargetsMap) async throws -> IInternalTarget {
        let buildTarget = try await log("Creating Build Target",
                                        auto: await buildTargetsManager.createTarget(dependencies: targets))
        try await log("Saving Project", auto: await xcodeProject.save())
        return buildTarget
    }

    func build(_ target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws {
        let dependenciesCount = target.explicitDependencies.count
        let title = "Build \(options.config): \(options.sdk.string)-\(options.arch) (\(dependenciesCount))"
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

            do {
                try await xcodeBuild.build(target: target.name, options: options, paths: paths)
                processInterruptionTask.cancel()
                await log("Cleaning Up", block: cleanup)
            } catch {
                processInterruptionTask.cancel()
                await log("Cleaning Up", block: cleanup)
                throw error
            }
        })
    }

    func build(targets: TargetsScope,
               targetsTryMode: Bool,
               options: XcodeBuildOptions,
               paths: XcodeBuildPaths,
               ignoreCache: Bool) async throws {
        let exactTargets = try await prepare(targets: targets,
                                             targetsTryMode: targetsTryMode,
                                             freeSpaceIfNeeded: true,
                                             patchLibraries: true)
        if targetsTryMode {
            return await targetsPrinter.print(exactTargets)
        }
        guard let buildTargets = try await reuseTargets(
            targets: exactTargets,
            options: options,
            ignoreCache: ignoreCache
        ) else { return }

        let buildTarget = try await makeBuildTarget(buildTargets)
        try await build(buildTarget, options: options, paths: paths)

        try await log(
            "Saving binaries (\(buildTarget.explicitDependencies.count))",
            auto: await binariesStorage.saveBinaries(ofTargets: buildTarget.explicitDependencies,
                                                     buildOptions: options,
                                                     buildPaths: paths)
        )
    }
}

// MARK: - IBuildManager

extension BuildManager: IBuildManager {
    public func build(targetsOptions: TargetsOptions,
                      options: XcodeBuildOptions,
                      paths: XcodeBuildPaths,
                      ignoreCache: Bool) async throws {
        try await environmentCollector.logXcodeVersion()
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        try await build(
            targets: .init(targetsOptions),
            targetsTryMode: targetsOptions.tryMode,
            options: options,
            paths: paths,
            ignoreCache: ignoreCache
        )
    }
}
