import Foundation

// MARK: - Interface

/// The manager to test in CocoaPods project.
public protocol ITestManager {
    /// Runs tests by impact or not.
    /// - Parameters:
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - buildOptions: Xcode build options.
    ///   - buildPaths: A collection of Xcode build paths.
    ///   - testPaths: A collection of Xcode tests paths.
    ///   - testplanTemplate: A testplan template to make the specific testplan.
    ///   - simulatorName: A name of simulator.
    ///   - byImpact: A flag to select test targets by impact.
    func test(targetsRegex: NSRegularExpression?,
              exceptTargetsRegex: NSRegularExpression?,
              buildOptions: XcodeBuildOptions,
              buildPaths: XcodeBuildPaths,
              testPaths: XcodeBuildPaths,
              testplanTemplate: String,
              simulatorName: String,
              byImpact: Bool) async throws
}

// MARK: - Implementation

final class TestManager: Loggable {
    let logger: ILogger
    private let environmentCollector: IEnvironmentCollector
    private let rugbyXcodeProject: IRugbyXcodeProject
    private let buildTargetsManager: IBuildTargetsManager
    private let useBinariesManager: IInternalUseBinariesManager
    private let buildManager: IInternalBuildManager
    private let xcodeProject: IInternalXcodeProject
    private let testplanEditor: ITestplanEditor
    private let xcodeBuild: IXcodeBuild
    private let testImpactManager: IInternalTestImpactManager
    private let backupManager: IBackupManager
    private let processMonitor: IProcessMonitor
    private let testsFolderPath: String

    init(logger: ILogger,
         environmentCollector: IEnvironmentCollector,
         rugbyXcodeProject: IRugbyXcodeProject,
         buildTargetsManager: IBuildTargetsManager,
         useBinariesManager: IInternalUseBinariesManager,
         buildManager: IInternalBuildManager,
         xcodeProject: IInternalXcodeProject,
         testplanEditor: ITestplanEditor,
         xcodeBuild: IXcodeBuild,
         testImpactManager: IInternalTestImpactManager,
         backupManager: IBackupManager,
         processMonitor: IProcessMonitor,
         testsFolderPath: String) {
        self.logger = logger
        self.environmentCollector = environmentCollector
        self.rugbyXcodeProject = rugbyXcodeProject
        self.buildTargetsManager = buildTargetsManager
        self.useBinariesManager = useBinariesManager
        self.buildManager = buildManager
        self.xcodeProject = xcodeProject
        self.testplanEditor = testplanEditor
        self.xcodeBuild = xcodeBuild
        self.testImpactManager = testImpactManager
        self.backupManager = backupManager
        self.processMonitor = processMonitor
        self.testsFolderPath = testsFolderPath
    }

    private func test(
        testTargets: TargetsMap,
        testplanTemplate: String,
        simulatorName: String,
        options: XcodeBuildOptions,
        paths: XcodeBuildPaths
    ) async throws {
        let testplanPath = try await log("Creating Test Plan", block: {
            try testplanEditor.createTestplan(
                withRelativeTemplatePath: testplanTemplate,
                testTargets: testTargets,
                inFolderPath: testsFolderPath
            )
        })

        let testsTarget = try await log("Creating Tests Target", block: {
            let target = try await buildTargetsManager.createTarget(
                dependencies: testTargets,
                buildConfiguration: options.config,
                testplanPath: testplanPath.path
            )
            try await xcodeProject.save()
            return target
        })

        let dependenciesCount = testsTarget.explicitDependencies.count
        let title = "Test \(options.config): \(options.sdk.string)-\(options.arch) (\(dependenciesCount))"
        let footer = "Test".green
        try await log(title, footer: footer, metricKey: "xcodebuild_test", level: .result, block: { [weak self] in
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
            try await xcodeBuild.test(
                scheme: testsTarget.name,
                testPlan: testplanPath.deletingPathExtension().lastPathComponent,
                simulatorName: simulatorName,
                options: options,
                paths: paths
            )
        })
    }
}

extension TestManager: ITestManager {
    private func selectingTargets(
        targetsRegex: NSRegularExpression?,
        exceptTargetsRegex: NSRegularExpression?,
        buildOptions: XcodeBuildOptions,
        byImpact: Bool,
        quiet: Bool = false
    ) async throws -> TargetsMap {
        guard byImpact else {
            let testTargets = try await testImpactManager.fetchTestTargets(
                targetsRegex,
                exceptTargetsRegex: exceptTargetsRegex,
                buildOptions: buildOptions,
                quiet: quiet
            )
            guard testTargets.isNotEmpty else {
                await log("No Targets to Test", level: quiet ? .info : .compact)
                return [:]
            }
            await log("Test Targets (\(testTargets.count))", level: quiet ? .info : .compact) {
                for target in testTargets.caseInsensitiveSortedByName() {
                    await log("\(target.name)", level: quiet ? .info : .result)
                }
            }
            return testTargets
        }

        let missingTestTargets = try await testImpactManager.missingTargets(
            targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            buildOptions: buildOptions,
            quiet: quiet
        )
        guard missingTestTargets.isNotEmpty else {
            await log("No Affected Test Targets", level: quiet ? .info : .compact)
            return [:]
        }
        await log("Affected Test Targets (\(missingTestTargets.count))", level: quiet ? .info : .compact) {
            for target in missingTestTargets.caseInsensitiveSortedByName() {
                await log("\(target.name)", level: quiet ? .info : .result)
            }
        }
        return missingTestTargets
    }

    func test(targetsRegex: NSRegularExpression?,
              exceptTargetsRegex: NSRegularExpression?,
              buildOptions: XcodeBuildOptions,
              buildPaths: XcodeBuildPaths,
              testPaths: XcodeBuildPaths,
              testplanTemplate: String,
              simulatorName: String,
              byImpact: Bool) async throws {
        try await environmentCollector.logXcodeVersion()
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let testTargets = try await log("Selecting Targets", block: {
            try await selectingTargets(
                targetsRegex: targetsRegex,
                exceptTargetsRegex: exceptTargetsRegex,
                buildOptions: buildOptions,
                byImpact: byImpact
            )
        })
        guard testTargets.isNotEmpty else { return }

        let updatedTestTargets = try await log("Caching Targets", block: {
            try await log(
                "Building",
                auto: await buildManager.build(
                    targets: .exact(testTargets.dependenciesMap()),
                    options: buildOptions,
                    paths: buildPaths,
                    ignoreCache: false
                )
            )
            return try await log("Using Binaries", block: {
                let updatedTestTargets = try await selectingTargets(
                    targetsRegex: targetsRegex,
                    exceptTargetsRegex: exceptTargetsRegex,
                    buildOptions: buildOptions,
                    byImpact: byImpact,
                    quiet: true
                )
                try await useBinariesManager.use(
                    targets: .exact(updatedTestTargets.dependenciesMap()),
                    xcargs: buildOptions.xcargs,
                    deleteSources: false
                )
                return updatedTestTargets
            })
        })

        try await log("Testing", block: {
            try await test(
                testTargets: updatedTestTargets,
                testplanTemplate: testplanTemplate,
                simulatorName: simulatorName,
                options: buildOptions,
                paths: testPaths
            )
        })
    }
}
