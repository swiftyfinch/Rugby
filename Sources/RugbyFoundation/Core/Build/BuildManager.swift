import Foundation

// MARK: - Interface

/// The protocol describing a manager to build CocoaPods project.
public protocol IBuildManager {
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

enum BuildError: LocalizedError {
    case buildFailed(errors: [String], buildLogPath: String, rawBuildLogPath: String)
    case cantFindBuildTargets

    var errorDescription: String? {
        switch self {
        case let .buildFailed(errors, buildLogPath, rawBuildLogPath):
            return """
            \("Build failed.".red)

            \(errors.joined(separator: "\n").white)
            \("🚑 More information in build logs:".yellow)
            \("[Beautified]".yellow) \("cat \(buildLogPath.homeFinderRelativePath())".white)
            \("[Raw]".yellow) \("open \(rawBuildLogPath.homeFinderRelativePath())".white)
            """
        case .cantFindBuildTargets:
            return "Couldn't find any build targets."
        }
    }
}

// MARK: - Implementation

final class BuildManager: Loggable {
    let logger: ILogger
    private let buildTargetsManager: BuildTargetsManager
    private let xcodeProject: XcodeProject
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
         xcodeProject: XcodeProject,
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

    private func makeBuildTarget(targets: [String: Target],
                                 options: XcodeBuildOptions,
                                 ignoreCache: Bool) async throws -> Target? {
        guard targets.isNotEmpty else { throw BuildError.cantFindBuildTargets }

        try await log("Backuping", auto: await backupManager.backup(xcodeProject, kind: .tmp))
        try await log("Checking Binaries Storage", auto: await binariesCleaner.freeSpace())
        try await log("Hashing Targets", auto: await targetsHasher.hash(targets, xcargs: options.xcargs))

        var shared: [String: Target] = [:]
        var buildTargets = targets
        if !ignoreCache {
            (shared, buildTargets) = try await log(
                "Finding Binaries",
                auto: binariesManager.findBinaries(ofTargets: buildTargets, buildOptions: options)
            )
        }
        guard buildTargets.isNotEmpty else {
            await log("Found 100% Binaries (\(targets.count))")
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
            await log("Found \(percent)% Binaries (\(shared.count)/\(targets.count))")

            await log("Reusing Binaries: \n\(shared.values.map { "* \($0.name)" }.sorted().joined(separator: "\n"))",
                      level: .info)
            try await log("Reusing Binaries", auto: await useBinariesManager.use(targets: shared, keepGroups: true))

            try await log("Saving Project", auto: await xcodeProject.save())
            xcodeProject.resetCache()
        }

        let buildTarget = try await log("Creating Build Target",
                                        auto: await buildTargetsManager.createTarget(dependencies: buildTargets))
        try await log("Saving Project", auto: await xcodeProject.save())

        return buildTarget
    }

    private func build(_ target: Target, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws {
        let title = "\(options.config): \(options.sdk.string)-\(options.arch) (\(target.explicitDependencies.count))"
        await log(
            "\(title)\n\(target.explicitDependencies.values.map { "* \($0.name)" }.sorted().joined(separator: "\n"))",
            level: .info
        )

        try await log(title, metricKey: "xcodebuild", block: { [weak self] in
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
        try await environmentCollector.logXcodeVersion()
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }
        let targets = try await log(
            "Finding Build Targets",
            auto: await buildTargetsManager.findTargets(targetsRegex, exceptTargets: exceptTargetsRegex)
        )
        let buildTarget = try await makeBuildTarget(targets: targets,
                                                    options: options,
                                                    ignoreCache: ignoreCache)
        guard let buildTarget else { return }
        try await build(buildTarget, options: options, paths: paths)

        try await log(
            "Saving binaries (\(buildTarget.explicitDependencies.count))",
            auto: await binariesManager.saveBinaries(ofTargets: buildTarget.explicitDependencies,
                                                     buildOptions: options,
                                                     buildPaths: paths)
        )
    }
}
