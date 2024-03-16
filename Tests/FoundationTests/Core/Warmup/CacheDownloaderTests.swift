import Fish
import Rainbow
@testable import RugbyFoundation
import XCTest

final class CacheDownloaderTests: XCTestCase {
    private var sut: ICacheDownloader!
    private var fishSharedStorage: IFilesManagerMock!
    private var logger: ILoggerMock!
    private var reachabilityChecker: IReachabilityCheckerMock!
    private var urlSession: IURLSessionMock!
    private var decompressor: IDecompressorMock!

    private enum TestError: Error {
        case test
    }

    override func setUp() {
        super.setUp()
        Rainbow.enabled = false

        fishSharedStorage = IFilesManagerMock()
        let backupFishSharedStorage = Fish.sharedStorage
        Fish.sharedStorage = fishSharedStorage
        addTeardownBlock {
            Fish.sharedStorage = backupFishSharedStorage
        }

        logger = ILoggerMock()
        reachabilityChecker = IReachabilityCheckerMock()
        urlSession = IURLSessionMock()
        decompressor = IDecompressorMock()
        sut = CacheDownloader(
            logger: logger,
            reachabilityChecker: reachabilityChecker,
            urlSession: urlSession,
            decompressor: decompressor
        )
    }

    override func tearDown() {
        super.tearDown()
        fishSharedStorage = nil
        logger = nil
        reachabilityChecker = nil
        urlSession = nil
        decompressor = nil
        sut = nil
    }
}

extension CacheDownloaderTests {
    func test_checkIfBinaryIsReachable_true() async {
        let url: URL! = URL(string: "https://github.com/swiftyfinch/Rugby")
        reachabilityChecker.checkIfURLIsReachableHeadersReturnValue = true

        // Act
        let isReachable = await sut.checkIfBinaryIsReachable(url: url, headers: [:])

        // Assert
        XCTAssertTrue(isReachable)
        XCTAssertEqual(reachabilityChecker.checkIfURLIsReachableHeadersCallsCount, 1)
        XCTAssertEqual(reachabilityChecker.checkIfURLIsReachableHeadersReceivedArguments?.url, url)
    }

    func test_checkIfBinaryIsReachable_false() async {
        let url: URL! = URL(string: "https://github.com/swiftyfinch/Rugby")
        reachabilityChecker.checkIfURLIsReachableHeadersReturnValue = false

        // Act
        let isReachable = await sut.checkIfBinaryIsReachable(url: url, headers: [:])

        // Assert
        XCTAssertFalse(isReachable)
        XCTAssertEqual(reachabilityChecker.checkIfURLIsReachableHeadersCallsCount, 1)
        XCTAssertEqual(reachabilityChecker.checkIfURLIsReachableHeadersReceivedArguments?.url, url)
    }

    func test_downloadBinary_failedDownloading() async {
        let url: URL! = URL(
            string: "https://s3.eu-west-2.amazonaws.com/rugby/bin/Alamofire/Debug-iphonesimulator-arm64/af22339"
        )
        let fileURL = URL(fileURLWithPath: "~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/af22339")
        urlSession.downloadForThrowableError = TestError.test

        // Act
        let isDownloaded = await sut.downloadBinary(url: url, headers: ["test_field": "test_value"], to: fileURL)

        // Assert
        XCTAssertFalse(isDownloaded)
        XCTAssertEqual(urlSession.downloadForCallsCount, 1)
        XCTAssertEqual(urlSession.downloadForReceivedRequest?.url, url)
        XCTAssertEqual(urlSession.downloadForReceivedRequest?.allHTTPHeaderFields?.count, 1)
        XCTAssertEqual(urlSession.downloadForReceivedRequest?.allHTTPHeaderFields?["test_field"], "test_value")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 2)
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[0].text,
            "Downloading \(url.absoluteString)"
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .file)
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[1].text,
            "Failed downloading \(url.absoluteString):\ntest"
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .file)
    }

    func test_downloadBinary_failedUnzipping() async {
        let url: URL! = URL(
            string: "https://s3.eu-west-2.amazonaws.com/rugby/bin/Alamofire/Debug-iphonesimulator-arm64/af22339"
        )
        let fileURL = URL(fileURLWithPath: "~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/af22339")
        let tmpFileURL = URL(fileURLWithPath: "/tmp/af22339.tmp")
        urlSession.downloadForReturnValue = tmpFileURL
        fishSharedStorage.createFolderAtReturnValue = IFolderMock()
        decompressor.unzipFileDestinationThrowableError = TestError.test

        // Act
        let isDownloaded = await sut.downloadBinary(url: url, headers: [:], to: fileURL)

        // Assert
        XCTAssertFalse(isDownloaded)
        XCTAssertEqual(urlSession.downloadForCallsCount, 1)
        XCTAssertEqual(urlSession.downloadForReceivedRequest?.url, url)
        XCTAssertEqual(fishSharedStorage.createFolderAtCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.createFolderAtReceivedPath, fileURL.path)
        XCTAssertEqual(decompressor.unzipFileDestinationCallsCount, 1)
        XCTAssertEqual(decompressor.unzipFileDestinationReceivedArguments?.zipFilePath, tmpFileURL)
        XCTAssertEqual(decompressor.unzipFileDestinationReceivedArguments?.destination, fileURL)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 3)
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[0].text,
            "Downloading \(url.absoluteString)"
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .file)
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[1].text,
            "Unzipping to \(fileURL.path)"
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .file)
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[2].text,
            "Failed unzipping to \(fileURL.path):\ntest"
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].output, .file)
    }

    func test_downloadBinary() async {
        let url: URL! = URL(
            string: "https://s3.eu-west-2.amazonaws.com/rugby/bin/Alamofire/Debug-iphonesimulator-arm64/af22339"
        )
        let fileURL = URL(fileURLWithPath: "~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/af22339")
        let tmpFileURL = URL(fileURLWithPath: "/tmp/af22339.tmp")
        urlSession.downloadForReturnValue = tmpFileURL
        fishSharedStorage.createFolderAtReturnValue = IFolderMock()

        // Act
        let isDownloaded = await sut.downloadBinary(url: url, headers: [:], to: fileURL)

        // Assert
        XCTAssertTrue(isDownloaded)
        XCTAssertEqual(urlSession.downloadForCallsCount, 1)
        XCTAssertEqual(urlSession.downloadForReceivedRequest?.url, url)
        XCTAssertEqual(fishSharedStorage.createFolderAtCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.createFolderAtReceivedPath, fileURL.path)
        XCTAssertEqual(decompressor.unzipFileDestinationCallsCount, 1)
        XCTAssertEqual(decompressor.unzipFileDestinationReceivedArguments?.zipFilePath, tmpFileURL)
        XCTAssertEqual(decompressor.unzipFileDestinationReceivedArguments?.destination, fileURL)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 2)
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[0].text,
            "Downloading \(url.absoluteString)"
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .file)
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[1].text,
            "Unzipping to \(fileURL.path)"
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].output, .file)
    }
}
