import Fish
import Rainbow
@testable import RugbyFoundation
import XCTest

// swiftlint:disable file_length line_length

final class TestManagerTests: XCTestCase {
    private enum TestError: Error { case test }

    private var sut: ITestManager!
    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!
    private var environmentCollector: IEnvironmentCollectorMock!
    private var rugbyXcodeProject: IRugbyXcodeProjectMock!
    private var buildTargetsManager: IBuildTargetsManagerMock!
    private var useBinariesManager: IInternalUseBinariesManagerMock!
    private var buildManager: IInternalBuildManagerMock!
    private var xcodeProject: IInternalXcodeProjectMock!
    private var testplanEditor: ITestplanEditorMock!
    private var xcodeBuild: IXcodeBuildMock!
    private var testImpactManager: IInternalTestImpactManagerMock!
    private var backupManager: IBackupManagerMock!
    private var processMonitor: IProcessMonitorMock!
    private var simCTL: ISimCTLMock!
    private var testsStorage: ITestsStorageMock!
    private var workingDirectory: IFolder!

    override func setUp() async throws {
        try await super.setUp()
        Rainbow.enabled = false
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        let testsFolder = try Folder.create(at: testsFolderURL.path)
        workingDirectory = try testsFolder.createFolder(named: "tests")
        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }
        environmentCollector = IEnvironmentCollectorMock()
        rugbyXcodeProject = IRugbyXcodeProjectMock()
        buildTargetsManager = IBuildTargetsManagerMock()
        useBinariesManager = IInternalUseBinariesManagerMock()
        buildManager = IInternalBuildManagerMock()
        xcodeProject = IInternalXcodeProjectMock()
        testplanEditor = ITestplanEditorMock()
        xcodeBuild = IXcodeBuildMock()
        testImpactManager = IInternalTestImpactManagerMock()
        backupManager = IBackupManagerMock()
        processMonitor = IProcessMonitorMock()
        simCTL = ISimCTLMock()
        testsStorage = ITestsStorageMock()
        sut = TestManager(
            logger: logger,
            environmentCollector: environmentCollector,
            rugbyXcodeProject: rugbyXcodeProject,
            buildTargetsManager: buildTargetsManager,
            useBinariesManager: useBinariesManager,
            buildManager: buildManager,
            xcodeProject: xcodeProject,
            testplanEditor: testplanEditor,
            xcodeBuild: xcodeBuild,
            testImpactManager: testImpactManager,
            backupManager: backupManager,
            processMonitor: processMonitor,
            simCTL: simCTL,
            testsStorage: testsStorage,
            testsFolderPath: workingDirectory.path
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        logger = nil
        loggerBlockInvocations = nil
        environmentCollector = nil
        rugbyXcodeProject = nil
        buildTargetsManager = nil
        useBinariesManager = nil
        buildManager = nil
        xcodeProject = nil
        testplanEditor = nil
        xcodeBuild = nil
        testImpactManager = nil
        backupManager = nil
        processMonitor = nil
        simCTL = nil
        testsStorage = nil
        workingDirectory = nil
    }
}

extension TestManagerTests {
    func test_testplanTemplatePath_error() async throws {
        testplanEditor.expandTestplanPathThrowableError = TestError.test

        // Act
        var resultError: Error?
        do {
            try await sut.test(
                targetsRegex: nil,
                exceptTargetsRegex: nil,
                buildOptions: .mock(),
                buildPaths: .mock(),
                testPaths: .mock(),
                testplanTemplatePath: "test_testplanTemplatePath",
                simulatorName: "iPhone 99",
                byImpact: true,
                markPassed: true
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? TestError, .test)
        XCTAssertTrue(testplanEditor.expandTestplanPathCalled)
    }

    func test_simulatorName_error() async throws {
        testplanEditor.expandTestplanPathReturnValue = "OK"
        simCTL.availableDevicesReturnValue = []
        let simulatorName = "iPhone 99"

        // Act
        var resultError: Error?
        do {
            try await sut.test(
                targetsRegex: nil,
                exceptTargetsRegex: nil,
                buildOptions: .mock(),
                buildPaths: .mock(),
                testPaths: .mock(),
                testplanTemplatePath: "test_testplanTemplatePath",
                simulatorName: simulatorName,
                byImpact: true,
                markPassed: true
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(
            (resultError as? TestManagerError)?.localizedDescription,
            "Can't find iOS simulator with name: \(simulatorName)"
        )
        XCTAssertTrue(testplanEditor.expandTestplanPathCalled)
        XCTAssertTrue(simCTL.availableDevicesCalled)
    }
}

extension TestManagerTests {
    func test_impact_noAffectedTestTargets() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let buildOptions: XcodeBuildOptions = .mock()
        let testplanTemplatePath = "test_testplanTemplate"
        testplanEditor.expandTestplanPathReturnValue = testplanTemplatePath
        let simulatorName = "iPhone 99"
        simCTL.availableDevicesReturnValue = [
            Device(
                udid: "test_udid",
                isAvailable: true,
                state: "test_state",
                name: simulatorName,
                runtime: "test_runtime"
            )
        ]
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        testImpactManager.missingTargetsExceptTargetsRegexBuildOptionsQuietReturnValue = [:]

        // Act
        try await sut.test(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            buildOptions: buildOptions,
            buildPaths: .mock(),
            testPaths: .mock(),
            testplanTemplatePath: testplanTemplatePath,
            simulatorName: simulatorName,
            byImpact: true,
            markPassed: true
        )

        // Assert
        XCTAssertTrue(logger.logListLevelOutputReceivedInvocations.isEmpty)
        XCTAssertTrue(logger.logPlainLevelOutputReceivedInvocations.isEmpty)

        XCTAssertEqual(testImpactManager.missingTargetsExceptTargetsRegexBuildOptionsQuietCallsCount, 1)
        let missingTargetsArguments = try XCTUnwrap(
            testImpactManager.missingTargetsExceptTargetsRegexBuildOptionsQuietReceivedArguments
        )
        XCTAssertEqual(missingTargetsArguments.targetsRegex, targetsRegex)
        XCTAssertEqual(missingTargetsArguments.exceptTargetsRegex, exceptTargetsRegex)
        XCTAssertEqual(missingTargetsArguments.buildOptions, buildOptions)

        let loggerBlockInvocations = try XCTUnwrap(loggerBlockInvocations)
        XCTAssertEqual(loggerBlockInvocations.count, 1)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Selecting Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "No Affected Test Targets")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
    }

    func test_impact() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let buildOptions: XcodeBuildOptions = .mock()
        let buildPaths: XcodeBuildPaths = .mock()
        let testplanTemplatePath = "test_testplanTemplate"
        testplanEditor.expandTestplanPathReturnValue = testplanTemplatePath
        let simulatorName = "iPhone 99"
        simCTL.availableDevicesReturnValue = [
            Device(
                udid: "test_udid",
                isAvailable: true,
                state: "test_state",
                name: simulatorName,
                runtime: "test_runtime"
            )
        ]
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let localPod = IInternalTargetMock()
        localPod.underlyingUuid = "localPod_uuid"
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.underlyingUuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.underlyingName = "LocalPod-framework-Unit-Tests"
        localPodFrameworkUnitTests.dependencies = [localPod.uuid: localPod]
        let localPodUnitResourceBundleTests = IInternalTargetMock()
        localPodUnitResourceBundleTests.underlyingUuid = "localPodUnitResourceBundleTests_uuid"
        localPodUnitResourceBundleTests.underlyingName = "LocalPod-Unit-ResourceBundleTests"
        let missingTargets = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodUnitResourceBundleTests.uuid: localPodUnitResourceBundleTests
        ]
        testImpactManager.missingTargetsExceptTargetsRegexBuildOptionsQuietReturnValue = missingTargets
        let testplanURL = URL(fileURLWithPath: "tests/Rugby.xctestplan")
        testplanEditor.createTestplanTestplanTemplatePathTestTargetsInFolderPathReturnValue = testplanURL
        let testsTarget = IInternalTargetMock()
        testsTarget.underlyingUuid = "test_RugbyPods_uuid"
        testsTarget.underlyingName = "RugbyPods"
        testsTarget.explicitDependencies = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodUnitResourceBundleTests.uuid: localPodUnitResourceBundleTests
        ]
        buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReturnValue = testsTarget
        processMonitor.runOnInterruptionReturnValue = ProcessInterruptionTask(job: {})

        // Act
        try await sut.test(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            buildOptions: buildOptions,
            buildPaths: buildPaths,
            testPaths: .mock(),
            testplanTemplatePath: testplanTemplatePath,
            simulatorName: simulatorName,
            byImpact: true,
            markPassed: true
        )

        // Assert
        XCTAssertTrue(logger.logListLevelOutputReceivedInvocations.isEmpty)
        XCTAssertTrue(logger.logPlainLevelOutputReceivedInvocations.isEmpty)

        XCTAssertEqual(testImpactManager.missingTargetsExceptTargetsRegexBuildOptionsQuietCallsCount, 2)
        let missingTargetsInvocations = testImpactManager.missingTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocations
        XCTAssertEqual(missingTargetsInvocations[0].targetsRegex, targetsRegex)
        XCTAssertEqual(missingTargetsInvocations[0].exceptTargetsRegex, exceptTargetsRegex)
        XCTAssertEqual(missingTargetsInvocations[0].buildOptions, buildOptions)
        XCTAssertFalse(missingTargetsInvocations[0].quiet)
        XCTAssertEqual(missingTargetsInvocations[1].targetsRegex, targetsRegex)
        XCTAssertEqual(missingTargetsInvocations[1].exceptTargetsRegex, exceptTargetsRegex)
        XCTAssertTrue(missingTargetsInvocations[1].quiet)

        let loggerBlockInvocations = try XCTUnwrap(loggerBlockInvocations)
        XCTAssertEqual(loggerBlockInvocations.count, 11)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Selecting Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Affected Test Targets (2)")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        let buildTargetsArguments = try XCTUnwrap(buildManager.buildTargetsOptionsPathsIgnoreCacheReceivedArguments)
        switch buildTargetsArguments.targets {
        case let .exact(targets):
            XCTAssertEqual(targets.count, 1)
            XCTAssertEqual(targets.values.first?.uuid, localPod.uuid)
        case .filter:
            XCTFail("Unexpected targets scope.")
        }
        XCTAssertEqual(buildTargetsArguments.options, buildOptions)
        XCTAssertEqual(buildTargetsArguments.paths, buildPaths)
        XCTAssertFalse(buildTargetsArguments.ignoreCache)

        XCTAssertEqual(useBinariesManager.useTargetsXcargsDeleteSourcesCallsCount, 1)
        let useTargetsArguments = try XCTUnwrap(useBinariesManager.useTargetsXcargsDeleteSourcesReceivedArguments)
        switch useTargetsArguments.targets {
        case let .exact(targets):
            XCTAssertEqual(targets.count, 1)
            XCTAssertEqual(targets.values.first?.uuid, localPod.uuid)
        case .filter:
            XCTFail("Unexpected targets scope.")
        }
        XCTAssertEqual(useTargetsArguments.xcargs, buildOptions.xcargs)
        XCTAssertFalse(useTargetsArguments.deleteSources)

        XCTAssertEqual(buildManager.buildTargetsOptionsPathsIgnoreCacheCallsCount, 1)
        XCTAssertEqual(loggerBlockInvocations[2].header, "Caching Targets")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)

        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
        XCTAssertEqual(loggerBlockInvocations[3].header, "Building")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)

        XCTAssertEqual(testplanEditor.createTestplanTestplanTemplatePathTestTargetsInFolderPathCallsCount, 1)
        let createTestplanArguments = try XCTUnwrap(
            testplanEditor.createTestplanTestplanTemplatePathTestTargetsInFolderPathReceivedArguments
        )
        XCTAssertEqual(createTestplanArguments.testTargets.count, 2)
        XCTAssertEqual(createTestplanArguments.folderPath, workingDirectory.path)
        XCTAssertEqual(createTestplanArguments.testplanTemplatePath, testplanTemplatePath)

        XCTAssertEqual(loggerBlockInvocations[4].header, "Using Binaries")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)

        XCTAssertEqual(buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathCallsCount, 1)
        let createTargetArguments = try XCTUnwrap(
            buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReceivedArguments
        )
        XCTAssertEqual(createTargetArguments.dependencies.count, 2)
        XCTAssertTrue(createTargetArguments.dependencies.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertTrue(createTargetArguments.dependencies.contains(localPodUnitResourceBundleTests.uuid))
        XCTAssertEqual(createTargetArguments.buildConfiguration, buildOptions.config)
        XCTAssertEqual(createTargetArguments.testplanPath, testplanURL.path)
        XCTAssertEqual(xcodeProject.saveCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations[5].header, "Affected Test Targets (2)")
        XCTAssertNil(loggerBlockInvocations[5].footer)
        XCTAssertNil(loggerBlockInvocations[5].metricKey)
        XCTAssertEqual(loggerBlockInvocations[5].level, .info)
        XCTAssertEqual(loggerBlockInvocations[5].output, .all)

        XCTAssertEqual(xcodeBuild.testSchemeTestPlanSimulatorNameOptionsPathsCallsCount, 1)
        let testArguments = try XCTUnwrap(xcodeBuild.testSchemeTestPlanSimulatorNameOptionsPathsReceivedArguments)
        XCTAssertEqual(testArguments.scheme, "RugbyPods")
        XCTAssertEqual(testArguments.testPlan, "Rugby")
        XCTAssertEqual(testArguments.simulatorName, simulatorName)
        XCTAssertEqual(testArguments.options, buildOptions)
        XCTAssertEqual(testArguments.paths, buildPaths)

        XCTAssertEqual(loggerBlockInvocations[6].header, "Testing")
        XCTAssertNil(loggerBlockInvocations[6].footer)
        XCTAssertNil(loggerBlockInvocations[6].metricKey)
        XCTAssertEqual(loggerBlockInvocations[6].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[6].output, .all)

        XCTAssertEqual(loggerBlockInvocations[7].header, "Creating Test Plan")
        XCTAssertNil(loggerBlockInvocations[7].footer)
        XCTAssertNil(loggerBlockInvocations[7].metricKey)
        XCTAssertEqual(loggerBlockInvocations[7].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[7].output, .all)

        XCTAssertEqual(loggerBlockInvocations[8].header, "Creating Tests Target")
        XCTAssertNil(loggerBlockInvocations[8].footer)
        XCTAssertNil(loggerBlockInvocations[8].metricKey)
        XCTAssertEqual(loggerBlockInvocations[8].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[8].output, .all)

        XCTAssertEqual(loggerBlockInvocations[9].header, "Test Debug: sim-arm64 (2)")
        XCTAssertEqual(loggerBlockInvocations[9].footer, "Test")
        XCTAssertEqual(loggerBlockInvocations[9].metricKey, "xcodebuild_test")
        XCTAssertEqual(loggerBlockInvocations[9].level, .result)
        XCTAssertEqual(loggerBlockInvocations[9].output, .all)

        XCTAssertEqual(xcodeProject.deleteTargetsKeepGroupsCallsCount, 1)
        let deleteTargetsArgs = try XCTUnwrap(xcodeProject.deleteTargetsKeepGroupsReceivedArguments)
        XCTAssertEqual(deleteTargetsArgs.targetsForRemove.count, 1)
        XCTAssertTrue(deleteTargetsArgs.targetsForRemove.contains(testsTarget.uuid))
        XCTAssertTrue(deleteTargetsArgs.keepGroups)

        XCTAssertEqual(loggerBlockInvocations[10].header, "Marking Tests as Passed")
        XCTAssertNil(loggerBlockInvocations[10].footer)
        XCTAssertNil(loggerBlockInvocations[10].metricKey)
        XCTAssertEqual(loggerBlockInvocations[10].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[10].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 4)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "LocalPod-framework-Unit-Tests")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].text, "LocalPod-Unit-ResourceBundleTests")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].text, "LocalPod-framework-Unit-Tests")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].level, .info)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].text, "LocalPod-Unit-ResourceBundleTests")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].level, .info)
    }
}

// MARK: - No Impact

extension TestManagerTests {
    func test_noImpact_noTargetsToTest() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let buildOptions: XcodeBuildOptions = .mock()
        let testplanTemplatePath = "test_testplanTemplate"
        let simulatorName = "iPhone 99"
        simCTL.availableDevicesReturnValue = [
            Device(
                udid: "test_udid",
                isAvailable: true,
                state: "test_state",
                name: simulatorName,
                runtime: "test_runtime"
            )
        ]
        testplanEditor.expandTestplanPathReturnValue = testplanTemplatePath
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        testImpactManager.fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReturnValue = [:]

        // Act
        try await sut.test(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            buildOptions: buildOptions,
            buildPaths: .mock(),
            testPaths: .mock(),
            testplanTemplatePath: testplanTemplatePath,
            simulatorName: simulatorName,
            byImpact: false,
            markPassed: false
        )

        // Assert
        XCTAssertTrue(logger.logListLevelOutputReceivedInvocations.isEmpty)
        XCTAssertTrue(logger.logPlainLevelOutputReceivedInvocations.isEmpty)

        XCTAssertEqual(testImpactManager.fetchTestTargetsExceptTargetsRegexBuildOptionsQuietCallsCount, 1)
        let fetchTestTargetsArguments = try XCTUnwrap(
            testImpactManager.fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReceivedArguments
        )
        XCTAssertEqual(fetchTestTargetsArguments.targetsRegex, targetsRegex)
        XCTAssertEqual(fetchTestTargetsArguments.exceptTargetsRegex, exceptTargetsRegex)
        XCTAssertEqual(fetchTestTargetsArguments.buildOptions, buildOptions)

        let loggerBlockInvocations = try XCTUnwrap(loggerBlockInvocations)
        XCTAssertEqual(loggerBlockInvocations.count, 1)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Selecting Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "No Targets to Test")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
    }

    func test_noImpact() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let buildOptions: XcodeBuildOptions = .mock()
        let buildPaths: XcodeBuildPaths = .mock()
        let testplanTemplatePath = "test_testplanTemplate"
        testplanEditor.expandTestplanPathReturnValue = testplanTemplatePath
        let simulatorName = "iPhone 99"
        simCTL.availableDevicesReturnValue = [
            Device(
                udid: "test_udid",
                isAvailable: true,
                state: "test_state",
                name: simulatorName,
                runtime: "test_runtime"
            )
        ]
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let localPod = IInternalTargetMock()
        localPod.underlyingUuid = "localPod_uuid"
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.underlyingUuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.underlyingName = "LocalPod-framework-Unit-Tests"
        localPodFrameworkUnitTests.dependencies = [localPod.uuid: localPod]
        let localPodUnitResourceBundleTests = IInternalTargetMock()
        localPodUnitResourceBundleTests.underlyingUuid = "localPodUnitResourceBundleTests_uuid"
        localPodUnitResourceBundleTests.underlyingName = "LocalPod-Unit-ResourceBundleTests"
        let missingTargets = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodUnitResourceBundleTests.uuid: localPodUnitResourceBundleTests
        ]
        testImpactManager.fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReturnValue = missingTargets
        let testplanURL = URL(fileURLWithPath: "tests/Rugby.xctestplan")
        testplanEditor.createTestplanTestplanTemplatePathTestTargetsInFolderPathReturnValue = testplanURL
        let testsTarget = IInternalTargetMock()
        testsTarget.underlyingUuid = "test_RugbyPods_uuid"
        testsTarget.underlyingName = "RugbyPods"
        testsTarget.explicitDependencies = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodUnitResourceBundleTests.uuid: localPodUnitResourceBundleTests
        ]
        buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReturnValue = testsTarget
        processMonitor.runOnInterruptionReturnValue = ProcessInterruptionTask(job: {})

        // Act
        try await sut.test(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            buildOptions: buildOptions,
            buildPaths: buildPaths,
            testPaths: .mock(),
            testplanTemplatePath: testplanTemplatePath,
            simulatorName: simulatorName,
            byImpact: false,
            markPassed: false
        )

        // Assert
        XCTAssertTrue(logger.logListLevelOutputReceivedInvocations.isEmpty)
        XCTAssertTrue(logger.logPlainLevelOutputReceivedInvocations.isEmpty)

        XCTAssertEqual(testImpactManager.fetchTestTargetsExceptTargetsRegexBuildOptionsQuietCallsCount, 2)
        let fetchTestTargetsInvocations = testImpactManager.fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocations
        XCTAssertEqual(fetchTestTargetsInvocations[0].targetsRegex, targetsRegex)
        XCTAssertEqual(fetchTestTargetsInvocations[0].exceptTargetsRegex, exceptTargetsRegex)
        XCTAssertEqual(fetchTestTargetsInvocations[0].buildOptions, buildOptions)
        XCTAssertFalse(fetchTestTargetsInvocations[0].quiet)
        XCTAssertEqual(fetchTestTargetsInvocations[1].targetsRegex, targetsRegex)
        XCTAssertEqual(fetchTestTargetsInvocations[1].exceptTargetsRegex, exceptTargetsRegex)
        XCTAssertEqual(fetchTestTargetsInvocations[1].buildOptions, buildOptions)
        XCTAssertTrue(fetchTestTargetsInvocations[1].quiet)

        let loggerBlockInvocations = try XCTUnwrap(loggerBlockInvocations)
        XCTAssertEqual(loggerBlockInvocations.count, 10)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Selecting Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Test Targets (2)")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        let buildTargetsArguments = try XCTUnwrap(buildManager.buildTargetsOptionsPathsIgnoreCacheReceivedArguments)
        switch buildTargetsArguments.targets {
        case let .exact(targets):
            XCTAssertEqual(targets.count, 1)
            XCTAssertEqual(targets.values.first?.uuid, localPod.uuid)
        case .filter:
            XCTFail("Unexpected targets scope.")
        }
        XCTAssertEqual(buildTargetsArguments.options, buildOptions)
        XCTAssertEqual(buildTargetsArguments.paths, buildPaths)
        XCTAssertFalse(buildTargetsArguments.ignoreCache)

        XCTAssertEqual(useBinariesManager.useTargetsXcargsDeleteSourcesCallsCount, 1)
        let useTargetsArguments = try XCTUnwrap(useBinariesManager.useTargetsXcargsDeleteSourcesReceivedArguments)
        switch useTargetsArguments.targets {
        case let .exact(targets):
            XCTAssertEqual(targets.count, 1)
            XCTAssertEqual(targets.values.first?.uuid, localPod.uuid)
        case .filter:
            XCTFail("Unexpected targets scope.")
        }
        XCTAssertEqual(useTargetsArguments.xcargs, buildOptions.xcargs)
        XCTAssertFalse(useTargetsArguments.deleteSources)

        XCTAssertEqual(buildManager.buildTargetsOptionsPathsIgnoreCacheCallsCount, 1)
        XCTAssertEqual(loggerBlockInvocations[2].header, "Caching Targets")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)

        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
        XCTAssertEqual(loggerBlockInvocations[3].header, "Building")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)

        XCTAssertEqual(testplanEditor.createTestplanTestplanTemplatePathTestTargetsInFolderPathCallsCount, 1)
        let createTestplanArguments = try XCTUnwrap(
            testplanEditor.createTestplanTestplanTemplatePathTestTargetsInFolderPathReceivedArguments
        )
        XCTAssertEqual(createTestplanArguments.testTargets.count, 2)
        XCTAssertEqual(createTestplanArguments.folderPath, workingDirectory.path)
        XCTAssertEqual(createTestplanArguments.testplanTemplatePath, testplanTemplatePath)

        XCTAssertEqual(loggerBlockInvocations[4].header, "Using Binaries")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)

        XCTAssertEqual(buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathCallsCount, 1)
        let createTargetArguments = try XCTUnwrap(
            buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReceivedArguments
        )
        XCTAssertEqual(createTargetArguments.dependencies.count, 2)
        XCTAssertTrue(createTargetArguments.dependencies.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertTrue(createTargetArguments.dependencies.contains(localPodUnitResourceBundleTests.uuid))
        XCTAssertEqual(createTargetArguments.buildConfiguration, buildOptions.config)
        XCTAssertEqual(createTargetArguments.testplanPath, testplanURL.path)
        XCTAssertEqual(xcodeProject.saveCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations[5].header, "Test Targets (2)")
        XCTAssertNil(loggerBlockInvocations[5].footer)
        XCTAssertNil(loggerBlockInvocations[5].metricKey)
        XCTAssertEqual(loggerBlockInvocations[5].level, .info)
        XCTAssertEqual(loggerBlockInvocations[5].output, .all)

        XCTAssertEqual(xcodeBuild.testSchemeTestPlanSimulatorNameOptionsPathsCallsCount, 1)
        let testArguments = try XCTUnwrap(xcodeBuild.testSchemeTestPlanSimulatorNameOptionsPathsReceivedArguments)
        XCTAssertEqual(testArguments.scheme, "RugbyPods")
        XCTAssertEqual(testArguments.testPlan, "Rugby")
        XCTAssertEqual(testArguments.simulatorName, simulatorName)
        XCTAssertEqual(testArguments.options, buildOptions)
        XCTAssertEqual(testArguments.paths, buildPaths)

        XCTAssertEqual(loggerBlockInvocations[6].header, "Testing")
        XCTAssertNil(loggerBlockInvocations[6].footer)
        XCTAssertNil(loggerBlockInvocations[6].metricKey)
        XCTAssertEqual(loggerBlockInvocations[6].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[6].output, .all)

        XCTAssertEqual(loggerBlockInvocations[7].header, "Creating Test Plan")
        XCTAssertNil(loggerBlockInvocations[7].footer)
        XCTAssertNil(loggerBlockInvocations[7].metricKey)
        XCTAssertEqual(loggerBlockInvocations[7].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[7].output, .all)

        XCTAssertEqual(loggerBlockInvocations[8].header, "Creating Tests Target")
        XCTAssertNil(loggerBlockInvocations[8].footer)
        XCTAssertNil(loggerBlockInvocations[8].metricKey)
        XCTAssertEqual(loggerBlockInvocations[8].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[8].output, .all)

        XCTAssertEqual(loggerBlockInvocations[9].header, "Test Debug: sim-arm64 (2)")
        XCTAssertEqual(loggerBlockInvocations[9].footer, "Test")
        XCTAssertEqual(loggerBlockInvocations[9].metricKey, "xcodebuild_test")
        XCTAssertEqual(loggerBlockInvocations[9].level, .result)
        XCTAssertEqual(loggerBlockInvocations[9].output, .all)

        XCTAssertEqual(xcodeProject.deleteTargetsKeepGroupsCallsCount, 1)
        let deleteTargetsArgs = try XCTUnwrap(xcodeProject.deleteTargetsKeepGroupsReceivedArguments)
        XCTAssertEqual(deleteTargetsArgs.targetsForRemove.count, 1)
        XCTAssertTrue(deleteTargetsArgs.targetsForRemove.contains(testsTarget.uuid))
        XCTAssertTrue(deleteTargetsArgs.keepGroups)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 4)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "LocalPod-framework-Unit-Tests")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].text, "LocalPod-Unit-ResourceBundleTests")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].text, "LocalPod-framework-Unit-Tests")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].level, .info)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].text, "LocalPod-Unit-ResourceBundleTests")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].level, .info)
    }
}

// swiftlint:enable file_length line_length
