import Rainbow
@testable import RugbyFoundation
import XCTest

// swiftlint:disable file_length

final class BuildManagerTests: XCTestCase {
    private enum TestError: Error { case test }

    private var sut: BuildManager!
    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!
    private var buildTargetsManager: IBuildTargetsManagerMock!
    private var librariesPatcher: ILibrariesPatcherMock!
    private var xcodeProject: IInternalXcodeProjectMock!
    private var rugbyXcodeProject: IRugbyXcodeProjectMock!
    private var backupManager: IBackupManagerMock!
    private var processMonitor: IProcessMonitorMock!
    private var xcodeBuild: IXcodeBuildMock!
    private var binariesStorage: IBinariesStorageMock!
    private var targetsHasher: ITargetsHasherMock!
    private var useBinariesManager: IUseBinariesManagerMock!
    private var binariesCleaner: IBinariesCleanerMock!
    private var environmentCollector: IEnvironmentCollectorMock!
    private var env: IEnvironmentMock!
    private var targetTreePainter: ITargetTreePainterMock!

    override func setUp() {
        super.setUp()
        Rainbow.enabled = false
        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }

        buildTargetsManager = IBuildTargetsManagerMock()
        librariesPatcher = ILibrariesPatcherMock()
        xcodeProject = IInternalXcodeProjectMock()
        rugbyXcodeProject = IRugbyXcodeProjectMock()
        backupManager = IBackupManagerMock()
        processMonitor = IProcessMonitorMock()
        xcodeBuild = IXcodeBuildMock()
        binariesStorage = IBinariesStorageMock()
        targetsHasher = ITargetsHasherMock()
        useBinariesManager = IUseBinariesManagerMock()
        binariesCleaner = IBinariesCleanerMock()
        environmentCollector = IEnvironmentCollectorMock()
        env = IEnvironmentMock()
        targetTreePainter = ITargetTreePainterMock()
        sut = BuildManager(
            logger: logger,
            buildTargetsManager: buildTargetsManager,
            librariesPatcher: librariesPatcher,
            xcodeProject: xcodeProject,
            rugbyXcodeProject: rugbyXcodeProject,
            backupManager: backupManager,
            processMonitor: processMonitor,
            xcodeBuild: xcodeBuild,
            binariesStorage: binariesStorage,
            targetsHasher: targetsHasher,
            useBinariesManager: useBinariesManager,
            binariesCleaner: binariesCleaner,
            environmentCollector: environmentCollector,
            env: env,
            targetTreePainter: targetTreePainter
        )
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        loggerBlockInvocations = nil
        buildTargetsManager = nil
        librariesPatcher = nil
        xcodeProject = nil
        rugbyXcodeProject = nil
        backupManager = nil
        processMonitor = nil
        xcodeBuild = nil
        binariesStorage = nil
        targetsHasher = nil
        useBinariesManager = nil
        binariesCleaner = nil
        environmentCollector = nil
        env = nil
        targetTreePainter = nil
        sut = nil
    }
}

extension BuildManagerTests {
    func test_build_isAlreadyUsingRugby() async throws {
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = true

        // Act
        var resultError: Error?
        do {
            try await sut.build(
                targetsRegex: nil,
                exceptTargetsRegex: nil,
                options: .mock(),
                paths: .mock(),
                ignoreCache: false
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

    func test_build_cantFindBuildTargets() async throws {
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [:]

        // Act
        var resultError: Error?
        do {
            try await sut.build(
                targetsRegex: nil,
                exceptTargetsRegex: nil,
                options: .mock(),
                paths: .mock(),
                ignoreCache: false
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(environmentCollector.logXcodeVersionCallsCount, 1)
        XCTAssertEqual(rugbyXcodeProject.isAlreadyUsingRugbyCallsCount, 1)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        XCTAssertEqual(resultError as? BuildError, .cantFindBuildTargets)
        XCTAssertEqual(resultError?.localizedDescription, "Couldn\'t find any build targets.")
    }

    func test_build_foundAllBinaries() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let targets = [
            alamofire.uuid: alamofire,
            snapkit.uuid: snapkit,
            moya.uuid: moya
        ]
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = targets
        binariesStorage.findBinariesOfTargetsBuildOptionsReturnValue = (targets, [:])
        let buildOptions: XcodeBuildOptions = .mock()

        // Act
        try await sut.build(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: buildOptions,
            paths: .mock(),
            ignoreCache: false
        )

        // Assert
        XCTAssertEqual(environmentCollector.logXcodeVersionCallsCount, 1)
        XCTAssertEqual(rugbyXcodeProject.isAlreadyUsingRugbyCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations.count, 6)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)

        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)

        XCTAssertEqual(loggerBlockInvocations[1].header, "Backuping")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .info)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)
        XCTAssertEqual(backupManager.backupKindCallsCount, 1)
        XCTAssertIdentical(backupManager.backupKindReceivedArguments?.xcodeProject, xcodeProject)
        XCTAssertEqual(backupManager.backupKindReceivedArguments?.kind, .tmp)

        XCTAssertEqual(loggerBlockInvocations[2].header, "Checking Binaries Storage")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
        XCTAssertEqual(binariesCleaner.freeSpaceCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations[3].header, "Patching Libraries")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .info)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)
        XCTAssertEqual(librariesPatcher.patchCallsCount, 1)
        let patchReceivedTargets = try XCTUnwrap(librariesPatcher.patchReceivedTargets)
        XCTAssertEqual(patchReceivedTargets.count, 3)
        XCTAssertTrue(patchReceivedTargets.contains(alamofire.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(moya.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[4].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)
        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashXcargsReceivedArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashXcargsReceivedArguments.targets.count, 3)
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(moya.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[5].header, "Finding Binaries")
        XCTAssertNil(loggerBlockInvocations[5].footer)
        XCTAssertNil(loggerBlockInvocations[5].metricKey)
        XCTAssertEqual(loggerBlockInvocations[5].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[5].output, .all)
        XCTAssertEqual(binariesStorage.findBinariesOfTargetsBuildOptionsCallsCount, 1)
        let findBinariesArguments = try XCTUnwrap(binariesStorage.findBinariesOfTargetsBuildOptionsReceivedArguments)
        XCTAssertEqual(findBinariesArguments.targets.count, 3)
        XCTAssertTrue(findBinariesArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(moya.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertEqual(findBinariesArguments.buildOptions, buildOptions)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Found 100% Binaries (3)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
    }

    func test_build_cantMakeBuildTarget() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        alamofire.underlyingName = "Alamofire"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        moya.underlyingName = "Moya"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        snapkit.underlyingName = "SnapKit"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let targets = [
            alamofire.uuid: alamofire,
            snapkit.uuid: snapkit,
            moya.uuid: moya
        ]
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = targets
        binariesStorage.findBinariesOfTargetsBuildOptionsReturnValue = (
            [alamofire.uuid: alamofire],
            [snapkit.uuid: snapkit, moya.uuid: moya]
        )
        env.underlyingPrintMissingBinaries = true
        targetTreePainter.paintTargetsReturnValue = "test_paintTargets"
        buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathThrowableError = TestError.test
        let buildOptions: XcodeBuildOptions = .mock()

        // Act
        var resultError: Error?
        do {
            try await sut.build(
                targetsRegex: targetsRegex,
                exceptTargetsRegex: exceptTargetsRegex,
                options: buildOptions,
                paths: .mock(),
                ignoreCache: false
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(environmentCollector.logXcodeVersionCallsCount, 1)
        XCTAssertEqual(rugbyXcodeProject.isAlreadyUsingRugbyCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations.count, 9)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 2)
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations.count, 1)

        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)

        XCTAssertEqual(loggerBlockInvocations[1].header, "Backuping")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .info)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)
        XCTAssertEqual(backupManager.backupKindCallsCount, 1)
        XCTAssertIdentical(backupManager.backupKindReceivedArguments?.xcodeProject, xcodeProject)
        XCTAssertEqual(backupManager.backupKindReceivedArguments?.kind, .tmp)

        XCTAssertEqual(loggerBlockInvocations[2].header, "Checking Binaries Storage")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
        XCTAssertEqual(binariesCleaner.freeSpaceCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations[3].header, "Patching Libraries")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .info)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)
        XCTAssertEqual(librariesPatcher.patchCallsCount, 1)
        let patchReceivedTargets = try XCTUnwrap(librariesPatcher.patchReceivedTargets)
        XCTAssertEqual(patchReceivedTargets.count, 3)
        XCTAssertTrue(patchReceivedTargets.contains(alamofire.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(moya.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[4].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)
        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashXcargsReceivedArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashXcargsReceivedArguments.targets.count, 3)
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(moya.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[5].header, "Finding Binaries")
        XCTAssertNil(loggerBlockInvocations[5].footer)
        XCTAssertNil(loggerBlockInvocations[5].metricKey)
        XCTAssertEqual(loggerBlockInvocations[5].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[5].output, .all)
        XCTAssertEqual(binariesStorage.findBinariesOfTargetsBuildOptionsCallsCount, 1)
        let findBinariesArguments = try XCTUnwrap(binariesStorage.findBinariesOfTargetsBuildOptionsReceivedArguments)
        XCTAssertEqual(findBinariesArguments.targets.count, 3)
        XCTAssertTrue(findBinariesArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(moya.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertEqual(findBinariesArguments.buildOptions, buildOptions)

        XCTAssertEqual(targetTreePainter.paintTargetsCallsCount, 1)
        let paintTargetsReceivedTargets = try XCTUnwrap(targetTreePainter.paintTargetsReceivedTargets)
        XCTAssertEqual(paintTargetsReceivedTargets.count, 2)
        XCTAssertTrue(paintTargetsReceivedTargets.contains(moya.uuid))
        XCTAssertTrue(paintTargetsReceivedTargets.contains(snapkit.uuid))
        XCTAssertEqual(
            logger.logPlainLevelOutputReceivedInvocations[0].text,
            """
            . Missing Binaries (2)
            test_paintTargets
            """
        )
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Found 33% Binaries (1/3)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[1].text,
            """
            Reusing Binaries:
            * Alamofire
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .info)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .all)

        XCTAssertEqual(loggerBlockInvocations[6].header, "Reusing Binaries")
        XCTAssertNil(loggerBlockInvocations[6].footer)
        XCTAssertNil(loggerBlockInvocations[6].metricKey)
        XCTAssertEqual(loggerBlockInvocations[6].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[6].output, .all)
        XCTAssertEqual(useBinariesManager.useTargetsKeepGroupsCallsCount, 1)
        let useTargetsArguments = try XCTUnwrap(useBinariesManager.useTargetsKeepGroupsReceivedArguments)
        XCTAssertEqual(useTargetsArguments.targets.count, 1)
        XCTAssertTrue(useTargetsArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(useTargetsArguments.keepGroups)

        XCTAssertEqual(loggerBlockInvocations[7].header, "Saving Project")
        XCTAssertNil(loggerBlockInvocations[7].footer)
        XCTAssertNil(loggerBlockInvocations[7].metricKey)
        XCTAssertEqual(loggerBlockInvocations[7].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[7].output, .all)
        XCTAssertEqual(xcodeProject.saveCallsCount, 1)
        XCTAssertEqual(xcodeProject.resetCacheCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations[8].header, "Creating Build Target")
        XCTAssertNil(loggerBlockInvocations[8].footer)
        XCTAssertNil(loggerBlockInvocations[8].metricKey)
        XCTAssertEqual(loggerBlockInvocations[8].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[8].output, .all)
        XCTAssertEqual(buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathCallsCount, 1)
        let createTargetDependencies = try XCTUnwrap(
            buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReceivedArguments?.dependencies
        )
        XCTAssertEqual(createTargetDependencies.count, 2)
        XCTAssertTrue(createTargetDependencies.contains(moya.uuid))
        XCTAssertTrue(createTargetDependencies.contains(snapkit.uuid))

        XCTAssertEqual(resultError as? TestError, .test)
    }

    func test_build_xcodeBuildError() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        alamofire.underlyingName = "Alamofire"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        moya.underlyingName = "Moya"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        snapkit.underlyingName = "SnapKit"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let targets = [
            alamofire.uuid: alamofire,
            snapkit.uuid: snapkit,
            moya.uuid: moya
        ]
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = targets
        binariesStorage.findBinariesOfTargetsBuildOptionsReturnValue = (
            [alamofire.uuid: alamofire],
            [snapkit.uuid: snapkit, moya.uuid: moya]
        )
        env.underlyingPrintMissingBinaries = true
        targetTreePainter.paintTargetsReturnValue = "test_paintTargets"
        let buildTarget = IInternalTargetMock()
        buildTarget.underlyingName = "RugbyPods"
        buildTarget.explicitDependencies = [
            snapkit.uuid: snapkit,
            moya.uuid: moya
        ]
        buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReturnValue = buildTarget
        xcodeBuild.buildTargetOptionsPathsThrowableError = TestError.test
        processMonitor.runOnInterruptionReturnValue = ProcessInterruptionTask(job: {})
        let buildOptions: XcodeBuildOptions = .mock()
        let buildPaths: XcodeBuildPaths = .mock()

        // Act
        var resultError: Error?
        do {
            try await sut.build(
                targetsRegex: targetsRegex,
                exceptTargetsRegex: exceptTargetsRegex,
                options: buildOptions,
                paths: buildPaths,
                ignoreCache: false
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(environmentCollector.logXcodeVersionCallsCount, 1)
        XCTAssertEqual(rugbyXcodeProject.isAlreadyUsingRugbyCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations.count, 11)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 3)
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations.count, 1)

        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)

        XCTAssertEqual(loggerBlockInvocations[1].header, "Backuping")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .info)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)
        XCTAssertEqual(backupManager.backupKindCallsCount, 1)
        XCTAssertIdentical(backupManager.backupKindReceivedArguments?.xcodeProject, xcodeProject)
        XCTAssertEqual(backupManager.backupKindReceivedArguments?.kind, .tmp)

        XCTAssertEqual(loggerBlockInvocations[2].header, "Checking Binaries Storage")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
        XCTAssertEqual(binariesCleaner.freeSpaceCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations[3].header, "Patching Libraries")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .info)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)
        XCTAssertEqual(librariesPatcher.patchCallsCount, 1)
        let patchReceivedTargets = try XCTUnwrap(librariesPatcher.patchReceivedTargets)
        XCTAssertEqual(patchReceivedTargets.count, 3)
        XCTAssertTrue(patchReceivedTargets.contains(alamofire.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(moya.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[4].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)
        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashXcargsReceivedArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashXcargsReceivedArguments.targets.count, 3)
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(moya.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[5].header, "Finding Binaries")
        XCTAssertNil(loggerBlockInvocations[5].footer)
        XCTAssertNil(loggerBlockInvocations[5].metricKey)
        XCTAssertEqual(loggerBlockInvocations[5].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[5].output, .all)
        XCTAssertEqual(binariesStorage.findBinariesOfTargetsBuildOptionsCallsCount, 1)
        let findBinariesArguments = try XCTUnwrap(binariesStorage.findBinariesOfTargetsBuildOptionsReceivedArguments)
        XCTAssertEqual(findBinariesArguments.targets.count, 3)
        XCTAssertTrue(findBinariesArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(moya.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertEqual(findBinariesArguments.buildOptions, buildOptions)

        XCTAssertEqual(targetTreePainter.paintTargetsCallsCount, 1)
        let paintTargetsReceivedTargets = try XCTUnwrap(targetTreePainter.paintTargetsReceivedTargets)
        XCTAssertEqual(paintTargetsReceivedTargets.count, 2)
        XCTAssertTrue(paintTargetsReceivedTargets.contains(moya.uuid))
        XCTAssertTrue(paintTargetsReceivedTargets.contains(snapkit.uuid))
        XCTAssertEqual(
            logger.logPlainLevelOutputReceivedInvocations[0].text,
            """
            . Missing Binaries (2)
            test_paintTargets
            """
        )
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Found 33% Binaries (1/3)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[1].text,
            """
            Reusing Binaries:
            * Alamofire
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .info)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .all)

        XCTAssertEqual(loggerBlockInvocations[6].header, "Reusing Binaries")
        XCTAssertNil(loggerBlockInvocations[6].footer)
        XCTAssertNil(loggerBlockInvocations[6].metricKey)
        XCTAssertEqual(loggerBlockInvocations[6].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[6].output, .all)
        XCTAssertEqual(useBinariesManager.useTargetsKeepGroupsCallsCount, 1)
        let useTargetsArguments = try XCTUnwrap(useBinariesManager.useTargetsKeepGroupsReceivedArguments)
        XCTAssertEqual(useTargetsArguments.targets.count, 1)
        XCTAssertTrue(useTargetsArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(useTargetsArguments.keepGroups)

        XCTAssertEqual(loggerBlockInvocations[7].header, "Saving Project")
        XCTAssertNil(loggerBlockInvocations[7].footer)
        XCTAssertNil(loggerBlockInvocations[7].metricKey)
        XCTAssertEqual(loggerBlockInvocations[7].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[7].output, .all)
        XCTAssertEqual(xcodeProject.saveCallsCount, 2)
        XCTAssertEqual(xcodeProject.resetCacheCallsCount, 2)

        XCTAssertEqual(loggerBlockInvocations[8].header, "Creating Build Target")
        XCTAssertNil(loggerBlockInvocations[8].footer)
        XCTAssertNil(loggerBlockInvocations[8].metricKey)
        XCTAssertEqual(loggerBlockInvocations[8].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[8].output, .all)
        XCTAssertEqual(buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathCallsCount, 1)
        let createTargetDependencies = try XCTUnwrap(
            buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReceivedArguments?.dependencies
        )
        XCTAssertEqual(createTargetDependencies.count, 2)
        XCTAssertTrue(createTargetDependencies.contains(moya.uuid))
        XCTAssertTrue(createTargetDependencies.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[9].header, "Saving Project")
        XCTAssertNil(loggerBlockInvocations[9].footer)
        XCTAssertNil(loggerBlockInvocations[9].metricKey)
        XCTAssertEqual(loggerBlockInvocations[9].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[9].output, .all)

        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[2].text,
            """
            Build Debug: sim-arm64 (2)
            * Moya
            * SnapKit
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].level, .info)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].output, .all)

        XCTAssertEqual(loggerBlockInvocations[10].header, "Build Debug: sim-arm64 (2)")
        XCTAssertNil(loggerBlockInvocations[10].footer)
        XCTAssertEqual(loggerBlockInvocations[10].metricKey, "xcodebuild")
        XCTAssertEqual(loggerBlockInvocations[10].level, .result)
        XCTAssertEqual(loggerBlockInvocations[10].output, .all)
        XCTAssertEqual(backupManager.restoreCallsCount, 1)
        XCTAssertIdentical(backupManager.backupKindReceivedArguments?.xcodeProject, xcodeProject)
        XCTAssertEqual(backupManager.backupKindReceivedArguments?.kind, .tmp)

        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsCallsCount, 1)
        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsReceivedArguments?.target, buildTarget.name)
        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsReceivedArguments?.options, buildOptions)
        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsReceivedArguments?.paths, buildPaths)
        XCTAssertEqual(resultError as? TestError, .test)
    }

    func test_build_full() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        alamofire.underlyingName = "Alamofire"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        moya.underlyingName = "Moya"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        snapkit.underlyingName = "SnapKit"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let targets = [
            alamofire.uuid: alamofire,
            snapkit.uuid: snapkit,
            moya.uuid: moya
        ]
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = targets
        binariesStorage.findBinariesOfTargetsBuildOptionsReturnValue = (
            [alamofire.uuid: alamofire],
            [snapkit.uuid: snapkit, moya.uuid: moya]
        )
        env.underlyingPrintMissingBinaries = true
        targetTreePainter.paintTargetsReturnValue = "test_paintTargets"
        let buildTarget = IInternalTargetMock()
        buildTarget.underlyingName = "RugbyPods"
        buildTarget.explicitDependencies = [
            snapkit.uuid: snapkit,
            moya.uuid: moya
        ]
        buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReturnValue = buildTarget
        processMonitor.runOnInterruptionReturnValue = ProcessInterruptionTask(job: {})
        let buildOptions: XcodeBuildOptions = .mock()
        let buildPaths: XcodeBuildPaths = .mock()

        // Act
        try await sut.build(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: buildOptions,
            paths: buildPaths,
            ignoreCache: false
        )

        // Assert
        XCTAssertEqual(environmentCollector.logXcodeVersionCallsCount, 1)
        XCTAssertEqual(rugbyXcodeProject.isAlreadyUsingRugbyCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations.count, 12)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 3)
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations.count, 1)

        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)

        XCTAssertEqual(loggerBlockInvocations[1].header, "Backuping")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .info)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)
        XCTAssertEqual(backupManager.backupKindCallsCount, 1)
        XCTAssertIdentical(backupManager.backupKindReceivedArguments?.xcodeProject, xcodeProject)
        XCTAssertEqual(backupManager.backupKindReceivedArguments?.kind, .tmp)

        XCTAssertEqual(loggerBlockInvocations[2].header, "Checking Binaries Storage")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
        XCTAssertEqual(binariesCleaner.freeSpaceCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations[3].header, "Patching Libraries")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .info)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)
        XCTAssertEqual(librariesPatcher.patchCallsCount, 1)
        let patchReceivedTargets = try XCTUnwrap(librariesPatcher.patchReceivedTargets)
        XCTAssertEqual(patchReceivedTargets.count, 3)
        XCTAssertTrue(patchReceivedTargets.contains(alamofire.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(moya.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[4].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)
        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashXcargsReceivedArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashXcargsReceivedArguments.targets.count, 3)
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(moya.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[5].header, "Finding Binaries")
        XCTAssertNil(loggerBlockInvocations[5].footer)
        XCTAssertNil(loggerBlockInvocations[5].metricKey)
        XCTAssertEqual(loggerBlockInvocations[5].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[5].output, .all)
        XCTAssertEqual(binariesStorage.findBinariesOfTargetsBuildOptionsCallsCount, 1)
        let findBinariesArguments = try XCTUnwrap(binariesStorage.findBinariesOfTargetsBuildOptionsReceivedArguments)
        XCTAssertEqual(findBinariesArguments.targets.count, 3)
        XCTAssertTrue(findBinariesArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(moya.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertEqual(findBinariesArguments.buildOptions, buildOptions)

        XCTAssertEqual(targetTreePainter.paintTargetsCallsCount, 1)
        let paintTargetsReceivedTargets = try XCTUnwrap(targetTreePainter.paintTargetsReceivedTargets)
        XCTAssertEqual(paintTargetsReceivedTargets.count, 2)
        XCTAssertTrue(paintTargetsReceivedTargets.contains(moya.uuid))
        XCTAssertTrue(paintTargetsReceivedTargets.contains(snapkit.uuid))
        XCTAssertEqual(
            logger.logPlainLevelOutputReceivedInvocations[0].text,
            """
            . Missing Binaries (2)
            test_paintTargets
            """
        )
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logPlainLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Found 33% Binaries (1/3)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[1].text,
            """
            Reusing Binaries:
            * Alamofire
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .info)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .all)

        XCTAssertEqual(loggerBlockInvocations[6].header, "Reusing Binaries")
        XCTAssertNil(loggerBlockInvocations[6].footer)
        XCTAssertNil(loggerBlockInvocations[6].metricKey)
        XCTAssertEqual(loggerBlockInvocations[6].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[6].output, .all)
        XCTAssertEqual(useBinariesManager.useTargetsKeepGroupsCallsCount, 1)
        let useTargetsArguments = try XCTUnwrap(useBinariesManager.useTargetsKeepGroupsReceivedArguments)
        XCTAssertEqual(useTargetsArguments.targets.count, 1)
        XCTAssertTrue(useTargetsArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(useTargetsArguments.keepGroups)

        XCTAssertEqual(loggerBlockInvocations[7].header, "Saving Project")
        XCTAssertNil(loggerBlockInvocations[7].footer)
        XCTAssertNil(loggerBlockInvocations[7].metricKey)
        XCTAssertEqual(loggerBlockInvocations[7].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[7].output, .all)
        XCTAssertEqual(xcodeProject.saveCallsCount, 2)
        XCTAssertEqual(xcodeProject.resetCacheCallsCount, 2)

        XCTAssertEqual(loggerBlockInvocations[8].header, "Creating Build Target")
        XCTAssertNil(loggerBlockInvocations[8].footer)
        XCTAssertNil(loggerBlockInvocations[8].metricKey)
        XCTAssertEqual(loggerBlockInvocations[8].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[8].output, .all)
        XCTAssertEqual(buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathCallsCount, 1)
        let createTargetDependencies = try XCTUnwrap(
            buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReceivedArguments?.dependencies
        )
        XCTAssertEqual(createTargetDependencies.count, 2)
        XCTAssertTrue(createTargetDependencies.contains(moya.uuid))
        XCTAssertTrue(createTargetDependencies.contains(snapkit.uuid))

        XCTAssertEqual(loggerBlockInvocations[9].header, "Saving Project")
        XCTAssertNil(loggerBlockInvocations[9].footer)
        XCTAssertNil(loggerBlockInvocations[9].metricKey)
        XCTAssertEqual(loggerBlockInvocations[9].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[9].output, .all)

        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[2].text,
            """
            Build Debug: sim-arm64 (2)
            * Moya
            * SnapKit
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].level, .info)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].output, .all)

        XCTAssertEqual(loggerBlockInvocations[10].header, "Build Debug: sim-arm64 (2)")
        XCTAssertNil(loggerBlockInvocations[10].footer)
        XCTAssertEqual(loggerBlockInvocations[10].metricKey, "xcodebuild")
        XCTAssertEqual(loggerBlockInvocations[10].level, .result)
        XCTAssertEqual(loggerBlockInvocations[10].output, .all)
        XCTAssertEqual(backupManager.restoreCallsCount, 1)
        XCTAssertIdentical(backupManager.backupKindReceivedArguments?.xcodeProject, xcodeProject)
        XCTAssertEqual(backupManager.backupKindReceivedArguments?.kind, .tmp)

        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsCallsCount, 1)
        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsReceivedArguments?.target, buildTarget.name)
        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsReceivedArguments?.options, buildOptions)
        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsReceivedArguments?.paths, buildPaths)

        XCTAssertEqual(loggerBlockInvocations[11].header, "Saving binaries (2)")
        XCTAssertNil(loggerBlockInvocations[11].footer)
        XCTAssertNil(loggerBlockInvocations[11].metricKey)
        XCTAssertEqual(loggerBlockInvocations[11].level, .result)
        XCTAssertEqual(loggerBlockInvocations[11].output, .all)
        XCTAssertEqual(binariesStorage.saveBinariesOfTargetsBuildOptionsBuildPathsCallsCount, 1)
        let saveBinariesArguments = try XCTUnwrap(
            binariesStorage.saveBinariesOfTargetsBuildOptionsBuildPathsReceivedArguments
        )
        XCTAssertEqual(saveBinariesArguments.targets.count, 2)
        XCTAssertTrue(saveBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertTrue(saveBinariesArguments.targets.contains(moya.uuid))
        XCTAssertEqual(saveBinariesArguments.buildOptions, buildOptions)
        XCTAssertEqual(saveBinariesArguments.buildPaths, buildPaths)
    }
}

extension BuildManagerTests {
    func test_prepare_patchLibrariesFalse_freeSpaceIfNeededFalse() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "test_targetsRegex")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "test_exceptTargetsRegex")
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [snapkit.uuid: snapkit]

        // Act
        _ = try await sut.prepare(
            targets: .filter(regex: targetsRegex, exceptRegex: exceptTargetsRegex),
            freeSpaceIfNeeded: false,
            patchLibraries: false
        )

        // Assert
        XCTAssertFalse(environmentCollector.logXcodeVersionCalled)
        XCTAssertFalse(rugbyXcodeProject.isAlreadyUsingRugbyCalled)
        XCTAssertEqual(loggerBlockInvocations.count, 2)

        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)

        XCTAssertEqual(loggerBlockInvocations[1].header, "Backuping")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .info)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)
        XCTAssertEqual(backupManager.backupKindCallsCount, 1)
        XCTAssertIdentical(backupManager.backupKindReceivedArguments?.xcodeProject, xcodeProject)
        XCTAssertEqual(backupManager.backupKindReceivedArguments?.kind, .tmp)
    }

    func test_makeBuildTarget_saveProjectError() async throws {
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        buildTargetsManager.createTargetDependenciesBuildConfigurationTestplanPathReturnValue = IInternalTargetMock()
        xcodeProject.saveThrowableError = TestError.test

        // Act
        var resultError: Error?
        do {
            _ = try await sut.makeBuildTarget([snapkit.uuid: snapkit])
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? TestError, .test)
    }

    func test_xcodeBuild_interruption() async throws {
        let buildTarget = IInternalTargetMock()
        buildTarget.underlyingName = "RugbyPods"
        let processInterruptionTask = ProcessInterruptionTask(job: {})
        processMonitor.runOnInterruptionReturnValue = processInterruptionTask
        xcodeBuild.buildTargetOptionsPathsClosure = { _, _, _ in
            self.processMonitor.runOnInterruptionReceivedJob?()
        }

        // Act
        try await sut.build(buildTarget, options: .mock(), paths: .mock())

        // Assert
        XCTAssertTrue(processInterruptionTask.isCancelled)
        XCTAssertEqual(xcodeBuild.buildTargetOptionsPathsCallsCount, 1)
        XCTAssertEqual(backupManager.restoreCallsCount, 2)
        XCTAssertEqual(backupManager.restoreReceivedInvocations, [.tmp, .tmp])
        XCTAssertEqual(xcodeProject.resetCacheCallsCount, 2)
    }
}

// swiftlint:enable file_length
