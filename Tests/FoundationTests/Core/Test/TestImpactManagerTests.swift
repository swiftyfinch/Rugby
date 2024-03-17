import Rainbow
@testable import RugbyFoundation
import XCTest

// swiftlint:disable file_length

final class TestImpactManagerTests: XCTestCase {
    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!

    private var environmentCollector: IEnvironmentCollectorMock!
    private var rugbyXcodeProject: IRugbyXcodeProjectMock!
    private var buildTargetsManager: IBuildTargetsManagerMock!
    private var targetsHasher: ITargetsHasherMock!
    private var testsStorage: ITestsStorageMock!
    private var git: IGitMock!
    private var targetsPrinter: ITargetsPrinterMock!
    private var sut: ITestImpactManager!

    override func setUp() {
        super.setUp()
        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }
        Rainbow.enabled = false

        environmentCollector = IEnvironmentCollectorMock()
        rugbyXcodeProject = IRugbyXcodeProjectMock()
        buildTargetsManager = IBuildTargetsManagerMock()
        targetsHasher = ITargetsHasherMock()
        testsStorage = ITestsStorageMock()
        git = IGitMock()
        targetsPrinter = ITargetsPrinterMock()
        sut = TestImpactManager(
            logger: logger,
            environmentCollector: environmentCollector,
            rugbyXcodeProject: rugbyXcodeProject,
            buildTargetsManager: buildTargetsManager,
            targetsHasher: targetsHasher,
            testsStorage: testsStorage,
            git: git,
            targetsPrinter: targetsPrinter
        )
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        loggerBlockInvocations = nil
        environmentCollector = nil
        rugbyXcodeProject = nil
        buildTargetsManager = nil
        targetsHasher = nil
        testsStorage = nil
        git = nil
        targetsPrinter = nil
        sut = nil
    }
}

extension TestImpactManagerTests {
    func test_markAsPassed_isAlreadyUsingRugby() async throws {
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = true

        // Act
        var resultError: Error?
        do {
            try await sut.markAsPassed(
                targetsOptions: .init(),
                buildOptions: .mock(),
                upToDateBranch: nil
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertFalse(logger.logLevelOutputCalled)
        XCTAssertEqual(environmentCollector.logXcodeVersionCallsCount, 1)
        XCTAssertEqual(rugbyXcodeProject.isAlreadyUsingRugbyCallsCount, 1)
        XCTAssertEqual(resultError as? RugbyError, .alreadyUseRugby)
        XCTAssertEqual(
            resultError?.localizedDescription,
            """
            The project is already using 🏈 Rugby.
            🚑 Call "rugby rollback" or "pod install".
            """
        )
    }

    func test_markAsPassed() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let buildOptions = XcodeBuildOptions(
            sdk: .sim,
            config: "Debug",
            arch: "arm64",
            xcargs: ["COMPILER_INDEX_STORE_ENABLE=NO", "SWIFT_COMPILATION_MODE=wholemodule"],
            resultBundlePath: nil
        )
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let localPodFramework = IInternalTargetMock()
        localPodFramework.underlyingUuid = "localPodFramework_uuid"
        localPodFramework.underlyingIsTests = false
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.underlyingUuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.underlyingIsTests = true
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodFramework.uuid: localPodFramework
        ]

        // Act
        try await sut.markAsPassed(
            targetsOptions: .init(
                targetsRegex: targetsRegex,
                exceptTargetsRegex: exceptTargetsRegex
            ),
            buildOptions: buildOptions,
            upToDateBranch: nil
        )

        // Assert
        XCTAssertEqual(loggerBlockInvocations.count, 3)
        XCTAssertFalse(logger.logLevelOutputCalled)

        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargets = try XCTUnwrap(buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments)
        XCTAssertEqual(findTargets.targets, targetsRegex)
        XCTAssertEqual(findTargets.exceptTargets, exceptTargetsRegex)
        XCTAssertTrue(findTargets.includingTests)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Targets")
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashArguments.targets.count, 2)
        XCTAssertTrue(hashArguments.targets.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertTrue(hashArguments.targets.contains(localPodFramework.uuid))
        XCTAssertEqual(hashArguments.xcargs, buildOptions.xcargs)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Hashing Targets")
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        XCTAssertEqual(testsStorage.saveTestsOfBuildOptionsCallsCount, 1)
        let saveTestsArguments = try XCTUnwrap(testsStorage.saveTestsOfBuildOptionsReceivedArguments)
        XCTAssertEqual(saveTestsArguments.buildOptions, buildOptions)
        XCTAssertEqual(saveTestsArguments.targets.count, 1)
        XCTAssertTrue(saveTestsArguments.targets.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertEqual(loggerBlockInvocations[2].header, "Marking Tests as Passed")
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
    }

    func test_markAsPassed_upToDateBranch_hasUncommittedChanges() async throws {
        git.hasUncommittedChangesReturnValue = true

        // Act
        try await sut.markAsPassed(
            targetsOptions: .init(),
            buildOptions: .mock(),
            upToDateBranch: "main"
        )

        // Assert
        XCTAssertTrue(git.hasUncommittedChangesCalled)
        XCTAssertFalse(git.isBehindBranchCalled)

        XCTAssertEqual(logger.logLevelOutputCallsCount, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedArguments?.level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedArguments?.output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedArguments?.text,
                       "Skip: The current branch has uncommitted changes.")

        XCTAssertTrue(loggerBlockInvocations.isEmpty)
        XCTAssertFalse(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCalled)
        XCTAssertFalse(targetsHasher.hashXcargsCalled)
        XCTAssertFalse(testsStorage.saveTestsOfBuildOptionsCalled)
    }

    func test_markAsPassed_upToDateBranch_isBehind() async throws {
        git.hasUncommittedChangesReturnValue = false
        git.isBehindBranchReturnValue = true

        // Act
        try await sut.markAsPassed(
            targetsOptions: .init(),
            buildOptions: .mock(),
            upToDateBranch: "main"
        )

        // Assert
        XCTAssertTrue(git.hasUncommittedChangesCalled)
        XCTAssertTrue(git.isBehindBranchCalled)
        XCTAssertEqual(git.isBehindBranchReceivedBranch, "main")

        XCTAssertEqual(logger.logLevelOutputCallsCount, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedArguments?.level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedArguments?.output, .all)
        XCTAssertEqual(logger.logLevelOutputReceivedArguments?.text,
                       "Skip: The current branch is behind main.")

        XCTAssertTrue(loggerBlockInvocations.isEmpty)
        XCTAssertFalse(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCalled)
        XCTAssertFalse(targetsHasher.hashXcargsCalled)
        XCTAssertFalse(testsStorage.saveTestsOfBuildOptionsCalled)
    }

    func test_markAsPassed_upToDateBranch() async throws {
        git.hasUncommittedChangesReturnValue = false
        git.isBehindBranchReturnValue = false
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let buildOptions = XcodeBuildOptions(
            sdk: .sim,
            config: "Debug",
            arch: "arm64",
            xcargs: ["COMPILER_INDEX_STORE_ENABLE=NO", "SWIFT_COMPILATION_MODE=wholemodule"],
            resultBundlePath: nil
        )
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let localPodFramework = IInternalTargetMock()
        localPodFramework.underlyingUuid = "localPodFramework_uuid"
        localPodFramework.underlyingIsTests = false
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.underlyingUuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.underlyingIsTests = true
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodFramework.uuid: localPodFramework
        ]

        // Act
        try await sut.markAsPassed(
            targetsOptions: .init(
                targetsRegex: targetsRegex,
                exceptTargetsRegex: exceptTargetsRegex
            ),
            buildOptions: buildOptions,
            upToDateBranch: "dev"
        )

        // Assert
        XCTAssertTrue(git.hasUncommittedChangesCalled)
        XCTAssertTrue(git.isBehindBranchCalled)
        XCTAssertEqual(git.isBehindBranchReceivedBranch, "dev")

        XCTAssertEqual(loggerBlockInvocations.count, 3)
        XCTAssertFalse(logger.logLevelOutputCalled)

        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargets = try XCTUnwrap(buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments)
        XCTAssertEqual(findTargets.targets, targetsRegex)
        XCTAssertEqual(findTargets.exceptTargets, exceptTargetsRegex)
        XCTAssertTrue(findTargets.includingTests)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Targets")
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashArguments.targets.count, 2)
        XCTAssertTrue(hashArguments.targets.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertTrue(hashArguments.targets.contains(localPodFramework.uuid))
        XCTAssertEqual(hashArguments.xcargs, buildOptions.xcargs)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Hashing Targets")
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        XCTAssertEqual(testsStorage.saveTestsOfBuildOptionsCallsCount, 1)
        let saveTestsArguments = try XCTUnwrap(testsStorage.saveTestsOfBuildOptionsReceivedArguments)
        XCTAssertEqual(saveTestsArguments.buildOptions, buildOptions)
        XCTAssertEqual(saveTestsArguments.targets.count, 1)
        XCTAssertTrue(saveTestsArguments.targets.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertEqual(loggerBlockInvocations[2].header, "Marking Tests as Passed")
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
    }
}

extension TestImpactManagerTests {
    func test_impact_isAlreadyUsingRugby() async throws {
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = true

        // Act
        var resultError: Error?
        do {
            try await sut.impact(
                targetsOptions: .init(),
                buildOptions: .mock()
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(environmentCollector.logXcodeVersionCallsCount, 1)
        XCTAssertEqual(rugbyXcodeProject.isAlreadyUsingRugbyCallsCount, 1)
        XCTAssertEqual(resultError as? RugbyError, .alreadyUseRugby)
        XCTAssertEqual(
            resultError?.localizedDescription,
            """
            The project is already using 🏈 Rugby.
            🚑 Call "rugby rollback" or "pod install".
            """
        )
    }

    func test_impact() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let buildOptions = XcodeBuildOptions(
            sdk: .sim,
            config: "Debug",
            arch: "arm64",
            xcargs: ["COMPILER_INDEX_STORE_ENABLE=NO", "SWIFT_COMPILATION_MODE=wholemodule"],
            resultBundlePath: nil
        )
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let localPodFramework = IInternalTargetMock()
        localPodFramework.underlyingUuid = "localPodFramework_uuid"
        localPodFramework.underlyingIsTests = false
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.underlyingUuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.underlyingIsTests = true
        let localPodLibraryUnitTests = IInternalTargetMock()
        localPodLibraryUnitTests.underlyingUuid = "localPodLibraryUnitTests_uuid"
        localPodLibraryUnitTests.underlyingName = "LocalPod-library-Unit-Tests"
        localPodLibraryUnitTests.underlyingIsTests = true
        localPodLibraryUnitTests.hash = "1417ca1"
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodFramework.uuid: localPodFramework,
            localPodLibraryUnitTests.uuid: localPodLibraryUnitTests
        ]
        testsStorage.findMissingTestsOfBuildOptionsReturnValue = [
            localPodLibraryUnitTests.uuid: localPodLibraryUnitTests
        ]

        // Act
        try await sut.impact(
            targetsOptions: .init(
                targetsRegex: targetsRegex,
                exceptTargetsRegex: exceptTargetsRegex
            ),
            buildOptions: buildOptions
        )

        // Assert
        XCTAssertEqual(loggerBlockInvocations.count, 3)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)

        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargets = try XCTUnwrap(buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments)
        XCTAssertEqual(findTargets.targets, targetsRegex)
        XCTAssertEqual(findTargets.exceptTargets, exceptTargetsRegex)
        XCTAssertTrue(findTargets.includingTests)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Targets")
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashArguments.targets.count, 3)
        XCTAssertTrue(hashArguments.targets.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertTrue(hashArguments.targets.contains(localPodFramework.uuid))
        XCTAssertTrue(hashArguments.targets.contains(localPodLibraryUnitTests.uuid))
        XCTAssertEqual(hashArguments.xcargs, buildOptions.xcargs)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Hashing Targets")
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        let findMissingArguments = try XCTUnwrap(testsStorage.findMissingTestsOfBuildOptionsReceivedArguments)
        XCTAssertEqual(findMissingArguments.buildOptions, buildOptions)
        XCTAssertEqual(findMissingArguments.targets.count, 2)
        XCTAssertTrue(findMissingArguments.targets.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertTrue(findMissingArguments.targets.contains(localPodLibraryUnitTests.uuid))

        XCTAssertEqual(loggerBlockInvocations[2].header, "Affected Test Targets (1)")
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "LocalPod-library-Unit-Tests (1417ca1)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
    }

    func test_impact_noAffectedTestTargets() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let buildOptions = XcodeBuildOptions(
            sdk: .sim,
            config: "Debug",
            arch: "arm64",
            xcargs: ["COMPILER_INDEX_STORE_ENABLE=NO", "SWIFT_COMPILATION_MODE=wholemodule"],
            resultBundlePath: nil
        )
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let localPodFramework = IInternalTargetMock()
        localPodFramework.underlyingUuid = "localPodFramework_uuid"
        localPodFramework.underlyingIsTests = false
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.underlyingUuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.underlyingIsTests = true
        let localPodLibraryUnitTests = IInternalTargetMock()
        localPodLibraryUnitTests.underlyingUuid = "localPodLibraryUnitTests_uuid"
        localPodLibraryUnitTests.underlyingName = "LocalPod-library-Unit-Tests"
        localPodLibraryUnitTests.underlyingIsTests = true
        localPodLibraryUnitTests.hash = "1417ca1"
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodFramework.uuid: localPodFramework,
            localPodLibraryUnitTests.uuid: localPodLibraryUnitTests
        ]
        testsStorage.findMissingTestsOfBuildOptionsReturnValue = [:]

        // Act
        try await sut.impact(
            targetsOptions: .init(
                targetsRegex: targetsRegex,
                exceptTargetsRegex: exceptTargetsRegex
            ),
            buildOptions: buildOptions
        )

        // Assert
        XCTAssertEqual(loggerBlockInvocations.count, 2)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)

        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargets = try XCTUnwrap(buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments)
        XCTAssertEqual(findTargets.targets, targetsRegex)
        XCTAssertEqual(findTargets.exceptTargets, exceptTargetsRegex)
        XCTAssertTrue(findTargets.includingTests)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Targets")
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashArguments.targets.count, 3)
        XCTAssertTrue(hashArguments.targets.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertTrue(hashArguments.targets.contains(localPodFramework.uuid))
        XCTAssertTrue(hashArguments.targets.contains(localPodLibraryUnitTests.uuid))
        XCTAssertEqual(hashArguments.xcargs, buildOptions.xcargs)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Hashing Targets")
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        let findMissingArguments = try XCTUnwrap(testsStorage.findMissingTestsOfBuildOptionsReceivedArguments)
        XCTAssertEqual(findMissingArguments.buildOptions, buildOptions)
        XCTAssertEqual(findMissingArguments.targets.count, 2)
        XCTAssertTrue(findMissingArguments.targets.contains(localPodFrameworkUnitTests.uuid))
        XCTAssertTrue(findMissingArguments.targets.contains(localPodLibraryUnitTests.uuid))

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "No Affected Test Targets")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
    }
}

// swiftlint:enable file_length
