import Foundation

// MARK: - Interface

/// The manager to test in CocoaPods project.
public protocol ITestManager: AnyObject {
    /// Runs tests by impact or not.
    /// - Parameters:
    ///   - targetsOptions: A set of options to to select targets.
    ///   - buildOptions: Xcode build options.
    ///   - buildPaths: A collection of Xcode build paths.
    ///   - testPaths: A collection of Xcode tests paths.
    ///   - testplanTemplatePath: A testplan template to make the specific testplan.
    ///   - simulatorName: A name of simulator.
    ///   - byImpact: A flag to select test targets by impact.
    ///   - markPassed: Mark test targets as passed if all tests are succeed.
    func test(targetsOptions: TargetsOptions,
              buildOptions: XcodeBuildOptions,
              buildPaths: XcodeBuildPaths,
              testPaths: XcodeBuildPaths,
              testplanTemplatePath: String,
              simulatorName: String,
              byImpact: Bool,
              markPassed: Bool) async throws
}

enum TestManagerError: LocalizedError {
    case cantFindSimulator(String)

    var errorDescription: String? {
        switch self {
        case let .cantFindSimulator(name):
            return "Can't find iOS simulator with name: \(name)"
        }
    }
}

// MARK: - Implementation

final class TestManager: Loggable {
    typealias Error = TestManagerError

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
    private let simCTL: ISimCTL
    private let testsStorage: ITestsStorage
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
         simCTL: ISimCTL,
         testsStorage: ITestsStorage,
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
        self.simCTL = simCTL
        self.testsStorage = testsStorage
        self.testsFolderPath = testsFolderPath
    }

    private func validateSimulatorName(_ name: String) throws {
        let availableDevices = try simCTL.availableDevices()
        guard availableDevices.contains(where: { $0.name == name }) else {
            throw Error.cantFindSimulator(name)
        }
    }

    private func test(
        testTargets: TargetsMap,
        testplanTemplatePath: String,
        simulatorName: String,
        options: XcodeBuildOptions,
        paths: XcodeBuildPaths
    ) async throws {
        let testplanPath = try await log("Creating Test Plan", block: {
            try testplanEditor.createTestplan(
                testplanTemplatePath: testplanTemplatePath,
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

            let deleteTestsTargetScheme = {
                try await self.xcodeProject.deleteTargets([testsTarget.uuid: testsTarget])
            }
            do {
                try await xcodeBuild.test(
                    scheme: testsTarget.name,
                    testPlan: testplanPath.deletingPathExtension().lastPathComponent,
                    simulatorName: simulatorName,
                    options: options,
                    paths: paths
                )
                try await deleteTestsTargetScheme()
                processInterruptionTask.cancel()
                cleanup()
            } catch {
                try await deleteTestsTargetScheme()
                processInterruptionTask.cancel()
                cleanup()
                throw error
            }
        })
    }

    private func selectingTargets(
        targetsOptions: TargetsOptions,
        buildOptions: XcodeBuildOptions,
        byImpact: Bool,
        quiet: Bool = false
    ) async throws -> TargetsMap {
        guard byImpact else {
            let testTargets = try await testImpactManager.fetchTestTargets(
                targetsOptions: targetsOptions,
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
            targetsOptions: targetsOptions,
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

    private func cache(targetsOptions: TargetsOptions,
                       testTargets: TargetsMap,
                       buildOptions: XcodeBuildOptions,
                       buildPaths: XcodeBuildPaths,
                       byImpact: Bool) async throws -> TargetsMap {
        try await log(
            "Building",
            auto: await buildManager.build(
                targets: .exact(testTargets.dependenciesMap()),
                targetsTryMode: false,
                options: buildOptions,
                paths: buildPaths,
                ignoreCache: false
            )
        )
        return try await log("Using Binaries", block: {
            let updatedTestTargets = try await selectingTargets(
                targetsOptions: targetsOptions,
                buildOptions: buildOptions,
                byImpact: byImpact,
                quiet: true
            )
            try await useBinariesManager.use(
                targets: .exact(updatedTestTargets.dependenciesMap()),
                targetsTryMode: false,
                xcargs: buildOptions.xcargs,
                deleteSources: false
            )
            return updatedTestTargets
        })
    }
}

extension TestManager: ITestManager {
    func test(targetsOptions: TargetsOptions,
              buildOptions: XcodeBuildOptions,
              buildPaths: XcodeBuildPaths,
              testPaths: XcodeBuildPaths,
              testplanTemplatePath: String,
              simulatorName: String,
              byImpact: Bool,
              markPassed: Bool) async throws {
        let testplanTemplatePath = try testplanEditor.expandTestplanPath(testplanTemplatePath)
        try validateSimulatorName(simulatorName)
        try await environmentCollector.logXcodeVersion()
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let testTargets = try await log(
            "Selecting Targets",
            auto: await selectingTargets(
                targetsOptions: targetsOptions,
                buildOptions: buildOptions,
                byImpact: byImpact,
                quiet: targetsOptions.tryMode
            )
        )
        guard testTargets.isNotEmpty else { return }

        let updatedTestTargets = try await log(
            "Caching Targets",
            auto: await cache(
                targetsOptions: targetsOptions,
                testTargets: testTargets,
                buildOptions: buildOptions,
                buildPaths: buildPaths,
                byImpact: byImpact
            )
        )

        try await log("Testing", block: {
            try await test(
                testTargets: updatedTestTargets,
                testplanTemplatePath: testplanTemplatePath,
                simulatorName: simulatorName,
                options: buildOptions,
                paths: testPaths
            )
        })

        if markPassed {
            try await log(
                "Marking Tests as Passed",
                auto: await testsStorage.saveTests(of: updatedTestTargets, buildOptions: buildOptions)
            )
        }
    }
}
