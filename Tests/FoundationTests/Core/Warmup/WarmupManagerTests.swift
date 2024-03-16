import Rainbow
@testable import RugbyFoundation
import XCTest

// swiftlint:disable file_length cyclomatic_complexity

final class WarmupManagerTests: XCTestCase {
    private var sut: IWarmupManager!
    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!
    private var rugbyXcodeProject: IRugbyXcodeProjectMock!
    private var buildTargetsManager: IBuildTargetsManagerMock!
    private var binariesStorage: IBinariesStorageMock!
    private var targetsHasher: ITargetsHasherMock!
    private var cacheDownloader: ICacheDownloaderMock!
    private var metricsLogger: IMetricsLoggerMock!

    override func setUp() {
        super.setUp()
        Rainbow.enabled = false
        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }

        rugbyXcodeProject = IRugbyXcodeProjectMock()
        buildTargetsManager = IBuildTargetsManagerMock()
        binariesStorage = IBinariesStorageMock()
        targetsHasher = ITargetsHasherMock()
        cacheDownloader = ICacheDownloaderMock()
        metricsLogger = IMetricsLoggerMock()
        sut = WarmupManager(
            logger: logger,
            rugbyXcodeProject: rugbyXcodeProject,
            buildTargetsManager: buildTargetsManager,
            binariesStorage: binariesStorage,
            targetsHasher: targetsHasher,
            cacheDownloader: cacheDownloader,
            metricsLogger: metricsLogger
        )
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        loggerBlockInvocations = nil
        rugbyXcodeProject = nil
        buildTargetsManager = nil
        binariesStorage = nil
        targetsHasher = nil
        cacheDownloader = nil
        metricsLogger = nil
        sut = nil
    }
}

// MARK: - Errors

extension WarmupManagerTests {
    func test_incorrectEndpoint() async throws {
        let endpoint = " "

        // Act
        var resultError: Error?
        do {
            try await sut.warmup(
                mode: .analyse(endpoint: endpoint),
                targetsRegex: nil,
                exceptTargetsRegex: nil,
                options: .mock(),
                maxInParallel: 10,
                headers: [:]
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? WarmupManagerError, .incorrectEndpoint("https:// "))
        XCTAssertEqual(resultError?.localizedDescription, "Incorrect endpoint: https:// ")
    }

    func test_alreadyUseRugby() async throws {
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = true

        // Act
        var resultError: Error?
        do {
            try await sut.warmup(
                mode: .analyse(endpoint: nil),
                targetsRegex: nil,
                exceptTargetsRegex: nil,
                options: .mock(),
                maxInParallel: 10,
                headers: [:]
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? RugbyError, .alreadyUseRugby)
    }

    func test_cantFindBuildTargets() async throws {
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [:]

        // Act
        var resultError: Error?
        do {
            try await sut.warmup(
                mode: .analyse(endpoint: nil),
                targetsRegex: nil,
                exceptTargetsRegex: nil,
                options: .mock(),
                maxInParallel: 10,
                headers: [:]
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? BuildError, .cantFindBuildTargets)
    }
}

// MARK: - Analyse w/o endpoint

extension WarmupManagerTests {
    func test_warmup_analyse_foundAll() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire|SnapKit$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^Moya$")
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [
            alamofire.uuid: alamofire,
            snapkit.uuid: snapkit
        ]
        binariesStorage.findBinariesOfTargetsBuildOptionsReturnValue = (
            [snapkit.uuid: snapkit, alamofire.uuid: alamofire],
            [:]
        )
        let xcodeBuildOptions = XcodeBuildOptions.mock()

        // Act
        try await sut.warmup(
            mode: .analyse(endpoint: nil),
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: xcodeBuildOptions,
            maxInParallel: 10,
            headers: [:]
        )

        // Assert
        XCTAssertEqual(loggerBlockInvocations.count, 3)

        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashArguments.targets.count, 2)
        XCTAssertTrue(hashArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(hashArguments.targets.contains(snapkit.uuid))
        XCTAssertEqual(hashArguments.xcargs, xcodeBuildOptions.xcargs)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        let findBinariesArguments = try XCTUnwrap(binariesStorage.findBinariesOfTargetsBuildOptionsReceivedArguments)
        XCTAssertEqual(findBinariesArguments.targets.count, 2)
        XCTAssertTrue(findBinariesArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertEqual(findBinariesArguments.buildOptions, xcodeBuildOptions)
        XCTAssertEqual(loggerBlockInvocations[2].header, "Finding Binaries")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Found Locally: 100% (2/2)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
    }

    func test_warmup_analyse() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire|SnapKit$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^Moya$")
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [
            alamofire.uuid: alamofire,
            snapkit.uuid: snapkit,
            moya.uuid: moya
        ]
        binariesStorage.findBinariesOfTargetsBuildOptionsReturnValue = (
            [moya.uuid: moya],
            [snapkit.uuid: snapkit, alamofire.uuid: alamofire]
        )
        let xcodeBuildOptions = XcodeBuildOptions.mock()
        binariesStorage.finderBinaryFolderPathBuildOptionsClosure = { target, options in
            guard options == xcodeBuildOptions else { fatalError() }
            switch target.uuid {
            case alamofire.uuid:
                return "~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/dbe4415"
            case snapkit.uuid:
                return "~/.rugby/bin/SnapKit/Debug-iphonesimulator-arm64/eb56c2f"
            default: fatalError()
            }
        }

        // Act
        try await sut.warmup(
            mode: .analyse(endpoint: nil),
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: xcodeBuildOptions,
            maxInParallel: 10,
            headers: [:]
        )

        // Assert
        XCTAssertEqual(loggerBlockInvocations.count, 3)

        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashArguments.targets.count, 3)
        XCTAssertTrue(hashArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(hashArguments.targets.contains(snapkit.uuid))
        XCTAssertEqual(hashArguments.xcargs, xcodeBuildOptions.xcargs)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        let findBinariesArguments = try XCTUnwrap(binariesStorage.findBinariesOfTargetsBuildOptionsReceivedArguments)
        XCTAssertEqual(findBinariesArguments.targets.count, 3)
        XCTAssertTrue(findBinariesArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertEqual(findBinariesArguments.buildOptions, xcodeBuildOptions)
        XCTAssertEqual(loggerBlockInvocations[2].header, "Finding Binaries")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 2)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Not Found:")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].list, [
            "- ~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/dbe4415",
            "- ~/.rugby/bin/SnapKit/Debug-iphonesimulator-arm64/eb56c2f"
        ])
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].text, "Found Locally: 33% (1/3)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .all)
    }
}

// MARK: - Analyse with endpoint

extension WarmupManagerTests {
    func test_analyse_endpoint() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire|SnapKit$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^Moya$")
        let endpoint = "s3.eu-west-2.amazonaws.com"
        let xcodeBuildOptions = XcodeBuildOptions.mock()

        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [
            alamofire.uuid: alamofire,
            snapkit.uuid: snapkit,
            moya.uuid: moya
        ]
        binariesStorage.findBinariesOfTargetsBuildOptionsReturnValue = (
            [moya.uuid: moya],
            [snapkit.uuid: snapkit, alamofire.uuid: alamofire]
        )
        binariesStorage.finderBinaryFolderPathBuildOptionsClosure = { target, options in
            guard options == xcodeBuildOptions else { fatalError() }
            switch target.uuid {
            case alamofire.uuid:
                return "~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/dbe4415"
            case snapkit.uuid:
                return "~/.rugby/bin/SnapKit/Debug-iphonesimulator-arm64/eb56c2f"
            default: fatalError()
            }
        }
        binariesStorage.binaryRelativePathBuildOptionsClosure = { target, options in
            guard options == xcodeBuildOptions else { fatalError() }
            switch target.uuid {
            case alamofire.uuid:
                return "Alamofire/Debug-iphonesimulator-arm64/dbe4415"
            case snapkit.uuid:
                return "SnapKit/Debug-iphonesimulator-arm64/eb56c2f"
            default: fatalError()
            }
        }
        cacheDownloader.checkIfBinaryIsReachableUrlHeadersClosure = { url, _ in
            switch url.absoluteString {
            case "https://s3.eu-west-2.amazonaws.com/SnapKit/Debug-iphonesimulator-arm64/eb56c2f.zip":
                return true
            case "https://s3.eu-west-2.amazonaws.com/Alamofire/Debug-iphonesimulator-arm64/dbe4415.zip":
                return false
            default: fatalError()
            }
        }

        // Act
        try await sut.warmup(
            mode: .analyse(endpoint: endpoint),
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: xcodeBuildOptions,
            maxInParallel: 10,
            headers: [:]
        )

        // Assert
        XCTAssertEqual(loggerBlockInvocations.count, 4)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 4)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations.count, 1)

        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashArguments.targets.count, 3)
        XCTAssertTrue(hashArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(hashArguments.targets.contains(snapkit.uuid))
        XCTAssertTrue(hashArguments.targets.contains(moya.uuid))
        XCTAssertEqual(hashArguments.xcargs, xcodeBuildOptions.xcargs)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        let findBinariesArguments = try XCTUnwrap(binariesStorage.findBinariesOfTargetsBuildOptionsReceivedArguments)
        XCTAssertEqual(findBinariesArguments.targets.count, 3)
        XCTAssertTrue(findBinariesArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(moya.uuid))
        XCTAssertEqual(findBinariesArguments.buildOptions, xcodeBuildOptions)
        XCTAssertEqual(loggerBlockInvocations[2].header, "Finding Binaries")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Not Found:")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].list, [
            "- ~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/dbe4415",
            "- ~/.rugby/bin/SnapKit/Debug-iphonesimulator-arm64/eb56c2f"
        ])
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].level, .result)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].text, "Found Locally: 33% (1/3)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .all)

        let reachableInvocations = try XCTUnwrap(cacheDownloader.checkIfBinaryIsReachableUrlHeadersReceivedInvocations)
        XCTAssertEqual(reachableInvocations.count, 2)
        let sortedReachableInvocations = reachableInvocations.sorted { $0.url.absoluteString < $1.url.absoluteString }
        XCTAssertEqual(
            sortedReachableInvocations[0].url.absoluteString,
            "https://s3.eu-west-2.amazonaws.com/Alamofire/Debug-iphonesimulator-arm64/dbe4415.zip"
        )
        XCTAssertEqual(
            sortedReachableInvocations[1].url.absoluteString,
            "https://s3.eu-west-2.amazonaws.com/SnapKit/Debug-iphonesimulator-arm64/eb56c2f.zip"
        )
        XCTAssertEqual(loggerBlockInvocations[3].header, "Checking binaries reachability")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)

        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[2].text,
            """
            Unreachable:
            https://s3.eu-west-2.amazonaws.com/Alamofire/Debug-iphonesimulator-arm64/dbe4415.zip
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].output, .file)

        XCTAssertEqual(metricsLogger.logNameReceivedInvocations.count, 1)
        XCTAssertEqual(metricsLogger.logNameReceivedInvocations[0].name, "Found Remote Binaries Percent")
        XCTAssertEqual(metricsLogger.logNameReceivedInvocations[0].metric, 50.0)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].text, "Found Remotely: 50% (1/2)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].output, .all)
    }
}

// MARK: - General

extension WarmupManagerTests {
    func test() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire|SnapKit$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^Moya$")
        let endpoint = "s3.eu-west-2.amazonaws.com"
        let xcodeBuildOptions = XcodeBuildOptions.mock()

        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        let localPod = IInternalTargetMock()
        localPod.underlyingUuid = "test_localPod_uuid"
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [
            alamofire.uuid: alamofire,
            snapkit.uuid: snapkit,
            moya.uuid: moya,
            localPod.uuid: localPod
        ]
        binariesStorage.findBinariesOfTargetsBuildOptionsReturnValue = (
            [moya.uuid: moya],
            [snapkit.uuid: snapkit, alamofire.uuid: alamofire, localPod.uuid: localPod]
        )
        binariesStorage.finderBinaryFolderPathBuildOptionsClosure = { target, options in
            guard options == xcodeBuildOptions else { fatalError() }
            switch target.uuid {
            case alamofire.uuid:
                return "~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/dbe4415"
            case snapkit.uuid:
                return "~/.rugby/bin/SnapKit/Debug-iphonesimulator-arm64/eb56c2f"
            case localPod.uuid:
                return "~/.rugby/bin/LocalPod/Debug-iphonesimulator-arm64/b3035c7"
            default: fatalError()
            }
        }
        binariesStorage.binaryRelativePathBuildOptionsClosure = { target, options in
            guard options == xcodeBuildOptions else { fatalError() }
            switch target.uuid {
            case alamofire.uuid:
                return "Alamofire/Debug-iphonesimulator-arm64/dbe4415"
            case snapkit.uuid:
                return "SnapKit/Debug-iphonesimulator-arm64/eb56c2f"
            case localPod.uuid:
                return "LocalPod/Debug-iphonesimulator-arm64/b3035c7"
            default: fatalError()
            }
        }
        cacheDownloader.checkIfBinaryIsReachableUrlHeadersClosure = { url, _ in
            switch url.absoluteString {
            case "https://s3.eu-west-2.amazonaws.com/SnapKit/Debug-iphonesimulator-arm64/eb56c2f.zip":
                return true
            case "https://s3.eu-west-2.amazonaws.com/Alamofire/Debug-iphonesimulator-arm64/dbe4415.zip":
                return false
            case "https://s3.eu-west-2.amazonaws.com/LocalPod/Debug-iphonesimulator-arm64/b3035c7.zip":
                return true
            default: fatalError()
            }
        }
        cacheDownloader.downloadBinaryUrlHeadersToClosure = { url, _, _ in
            switch url.absoluteString {
            case "https://s3.eu-west-2.amazonaws.com/LocalPod/Debug-iphonesimulator-arm64/b3035c7.zip":
                return true
            case "https://s3.eu-west-2.amazonaws.com/SnapKit/Debug-iphonesimulator-arm64/eb56c2f.zip":
                return false
            default: fatalError()
            }
        }

        // Act
        try await sut.warmup(
            mode: .endpoint(endpoint),
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: xcodeBuildOptions,
            maxInParallel: 10,
            headers: ["test_field": "test_value"]
        )

        // Assert
        XCTAssertEqual(loggerBlockInvocations.count, 5)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 5)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations.count, 1)

        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        let findTargetsArguments = try XCTUnwrap(
            buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments
        )
        XCTAssertEqual(findTargetsArguments.targets, targetsRegex)
        XCTAssertEqual(findTargetsArguments.exceptTargets, exceptTargetsRegex)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashArguments.targets.count, 4)
        XCTAssertTrue(hashArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(hashArguments.targets.contains(snapkit.uuid))
        XCTAssertTrue(hashArguments.targets.contains(moya.uuid))
        XCTAssertTrue(hashArguments.targets.contains(localPod.uuid))
        XCTAssertEqual(hashArguments.xcargs, xcodeBuildOptions.xcargs)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        let findBinariesArguments = try XCTUnwrap(binariesStorage.findBinariesOfTargetsBuildOptionsReceivedArguments)
        XCTAssertEqual(findBinariesArguments.targets.count, 4)
        XCTAssertTrue(findBinariesArguments.targets.contains(alamofire.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(snapkit.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(moya.uuid))
        XCTAssertTrue(findBinariesArguments.targets.contains(localPod.uuid))
        XCTAssertEqual(findBinariesArguments.buildOptions, xcodeBuildOptions)
        XCTAssertEqual(loggerBlockInvocations[2].header, "Finding Binaries")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Not Found:")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .info)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].list, [
            "- ~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/dbe4415",
            "- ~/.rugby/bin/LocalPod/Debug-iphonesimulator-arm64/b3035c7",
            "- ~/.rugby/bin/SnapKit/Debug-iphonesimulator-arm64/eb56c2f"
        ])
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].level, .info)
        XCTAssertEqual(logger.logListLevelOutputReceivedInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].text, "Found Locally: 25% (1/4)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .result)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .all)

        let reachableInvocations = try XCTUnwrap(cacheDownloader.checkIfBinaryIsReachableUrlHeadersReceivedInvocations)
        XCTAssertEqual(reachableInvocations.count, 3)
        let sortedReachableInvocations = reachableInvocations.sorted { $0.url.absoluteString < $1.url.absoluteString }
        XCTAssertEqual(
            sortedReachableInvocations[0].url.absoluteString,
            "https://s3.eu-west-2.amazonaws.com/Alamofire/Debug-iphonesimulator-arm64/dbe4415.zip"
        )
        XCTAssertEqual(sortedReachableInvocations[0].headers, ["test_field": "test_value"])
        XCTAssertEqual(
            sortedReachableInvocations[1].url.absoluteString,
            "https://s3.eu-west-2.amazonaws.com/LocalPod/Debug-iphonesimulator-arm64/b3035c7.zip"
        )
        XCTAssertEqual(sortedReachableInvocations[1].headers, ["test_field": "test_value"])
        XCTAssertEqual(
            sortedReachableInvocations[2].url.absoluteString,
            "https://s3.eu-west-2.amazonaws.com/SnapKit/Debug-iphonesimulator-arm64/eb56c2f.zip"
        )
        XCTAssertEqual(sortedReachableInvocations[2].headers, ["test_field": "test_value"])
        XCTAssertEqual(loggerBlockInvocations[3].header, "Checking binaries reachability")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)

        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[2].text,
            """
            Unreachable:
            https://s3.eu-west-2.amazonaws.com/Alamofire/Debug-iphonesimulator-arm64/dbe4415.zip
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].output, .file)

        XCTAssertEqual(metricsLogger.logNameReceivedInvocations.count, 2)
        XCTAssertEqual(metricsLogger.logNameReceivedInvocations[0].name, "Found Remote Binaries Percent")
        XCTAssertEqual(metricsLogger.logNameReceivedInvocations[0].metric, 66.0)
        XCTAssertEqual(metricsLogger.logNameReceivedInvocations[1].name, "Downloaded Binaries Percent")
        XCTAssertEqual(metricsLogger.logNameReceivedInvocations[1].metric, 50.0)

        let downloadBinaryInvocations = cacheDownloader.downloadBinaryUrlHeadersToReceivedInvocations.sorted {
            $0.url.absoluteString < $1.url.absoluteString
        }
        XCTAssertEqual(downloadBinaryInvocations.count, 2)
        XCTAssertEqual(downloadBinaryInvocations[0].url.absoluteString,
                       "https://s3.eu-west-2.amazonaws.com/LocalPod/Debug-iphonesimulator-arm64/b3035c7.zip")
        XCTAssertEqual(downloadBinaryInvocations[0].headers, ["test_field": "test_value"])
        XCTAssertEqual(downloadBinaryInvocations[1].url.absoluteString,
                       "https://s3.eu-west-2.amazonaws.com/SnapKit/Debug-iphonesimulator-arm64/eb56c2f.zip")
        XCTAssertEqual(downloadBinaryInvocations[1].headers, ["test_field": "test_value"])

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].text, "Found Remotely: 66% (2/3)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].output, .all)

        XCTAssertEqual(loggerBlockInvocations[4].header, "Downloading binaries (2)")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[4].text, "Downloaded: 50% (1/2)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[4].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[4].output, .all)
    }
}

// swiftlint:enable file_length cyclomatic_complexity
