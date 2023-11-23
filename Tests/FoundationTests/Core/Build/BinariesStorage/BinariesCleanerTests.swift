import Fish
import Rainbow
@testable import RugbyFoundation
import XCTest

final class BinariesCleanerTests: XCTestCase {
    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!

    private var sharedRugbyFolder: IFolder!
    private var binariesFolder: IFolder!
    private var localRugbyFolder: IFolder!
    private var buildFolder: IFolder!

    override func setUp() async throws {
        try await super.setUp()

        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }
        Rainbow.enabled = false

        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        let testsFolder = try Folder.create(at: testsFolderURL.path)
        localRugbyFolder = try testsFolder.createFolder(named: ".rugby")
        buildFolder = try localRugbyFolder.createFolder(named: "build")
        sharedRugbyFolder = try testsFolder.createFolder(named: ".rugby_shared")
        binariesFolder = try sharedRugbyFolder.createFolder(named: "bin")
    }

    override func tearDown() async throws {
        try await super.tearDown()

        logger = nil
        loggerBlockInvocations = nil

        try sharedRugbyFolder.delete()
        sharedRugbyFolder = nil
        binariesFolder = nil
        try localRugbyFolder.delete()
        localRugbyFolder = nil
        buildFolder = nil
    }

    private func makeSut(limit: Int) -> IBinariesCleaner {
        BinariesCleaner(
            logger: logger,
            limit: limit,
            sharedRugbyFolderPath: sharedRugbyFolder.path,
            binariesFolderPath: binariesFolder.path,
            localRugbyFolderPath: localRugbyFolder.path,
            buildFolderPath: buildFolder.path
        )
    }
}

extension BinariesCleanerTests {
    func test_deleteBuildFolderOnly() async throws {
        try buildFolder.createFile(named: "test", contents: .generate())
        let sut = makeSut(limit: 500)

        // Act
        try await sut.freeSpace()

        // Assert
        try XCTAssertTrue(buildFolder.isEmpty())

        XCTAssertEqual(loggerBlockInvocations.count, 5)
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.footer == nil })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.metricKey == nil })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.level == .info })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.output == .all })
        XCTAssertEqual(loggerBlockInvocations[0].header, "Calculating Storage Info")
        XCTAssertEqual(loggerBlockInvocations[1].header, "Finding Candidates")
        XCTAssertEqual(loggerBlockInvocations[2].header, "Selecting Binaries")
        XCTAssertEqual(loggerBlockInvocations[3].header, "Removing files")
        XCTAssertEqual(loggerBlockInvocations[4].header, "Removing build folder")

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 6)
        XCTAssertTrue(logger.logLevelOutputReceivedInvocations.allSatisfy { $0.level == .info })
        XCTAssertTrue(logger.logLevelOutputReceivedInvocations.allSatisfy { $0.output == .all })
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Used: 432 bytes (86%)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].text, "Reserved: 518 bytes")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].text, "Limit: 500 bytes")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].text, "To Free: 132 bytes")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[4].text, "Can\'t add more paths to free space")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[5].text, "Freed: 432 bytes")
    }

    func test_deleteOldBinaryVariant_sameConfig_sdk_arch() async throws {
        let alamofire = try binariesFolder.createFolder(named: "Alamofire")
        let alamofire_arm64 = try alamofire.createFolder(named: "Debug-iphonesimulator-arm64")
        let hash_85d4367 = try alamofire_arm64.createFolder(named: "85d4367")
        let alamofireFramework_85d4367 = try hash_85d4367.createFolder(named: "Alamofire.framework")
        try alamofireFramework_85d4367.createFile(
            named: "test_alamofire_content_85d4367",
            contents: .generate(count: 39)
        )
        let hash_2b12f8a = try alamofire_arm64.createFolder(named: "2b12f8a")
        let alamofireFramework_2b12f8a = try hash_2b12f8a.createFolder(named: "Alamofire.framework")
        let test_alamofire_content_2b12f8a = try alamofireFramework_2b12f8a.createFile(
            named: "test_alamofire_content_2b12f8a",
            contents: .generate(count: 18)
        )
        let sut = makeSut(limit: 1000)

        // Act
        try await sut.freeSpace()

        // Assert
        let binaries = try binariesFolder.files(deep: true)
        XCTAssertEqual(binaries.count, 1)
        XCTAssertEqual(binaries[0].path, test_alamofire_content_2b12f8a.path)

        XCTAssertEqual(loggerBlockInvocations.count, 5)
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.footer == nil })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.metricKey == nil })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.level == .info })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.output == .all })
        XCTAssertEqual(loggerBlockInvocations[0].header, "Calculating Storage Info")
        XCTAssertEqual(loggerBlockInvocations[1].header, "Finding Candidates")
        XCTAssertEqual(loggerBlockInvocations[2].header, "Selecting Binaries")
        XCTAssertEqual(loggerBlockInvocations[3].header, "Removing files")
        XCTAssertEqual(loggerBlockInvocations[4].header, "Removing build folder")

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 7)
        XCTAssertTrue(logger.logLevelOutputReceivedInvocations.allSatisfy { $0.level == .info })
        XCTAssertTrue(logger.logLevelOutputReceivedInvocations.allSatisfy { $0.output == .all })
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Used: 2 KB (205%)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].text, "Reserved: 2 KB")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].text, "Limit: 1 KB")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].text, "To Free: 1 KB")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[4].text, "Can\'t add more paths to free space")
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[5].text,
            """
            Folders For Deletion:
            Alamofire.framework
            - \(hash_85d4367.path)
            + \(hash_2b12f8a.path)\n
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[6].text, "Freed: 1 KB")
    }

    func test_deleteOldBinaryVariant_differentArch() async throws {
        let alamofire = try binariesFolder.createFolder(named: "Alamofire")
        let alamofire_x86_64 = try alamofire.createFolder(named: "Debug-iphonesimulator-x86_64")
        let hash_2b12f8a = try alamofire_x86_64.createFolder(named: "2b12f8a")
        let alamofireFramework_2b12f8a = try hash_2b12f8a.createFolder(named: "Alamofire.framework")
        try alamofireFramework_2b12f8a.createFile(
            named: "test_alamofire_content_2b12f8a",
            contents: .generate(count: 18)
        )
        let alamofire_arm64 = try alamofire.createFolder(named: "Debug-iphonesimulator-arm64")
        let hash_85d4367 = try alamofire_arm64.createFolder(named: "85d4367")
        let alamofireFramework_85d4367 = try hash_85d4367.createFolder(named: "Alamofire.framework")
        let test_alamofire_content_85d4367 = try alamofireFramework_85d4367.createFile(
            named: "test_alamofire_content_85d4367",
            contents: .generate(count: 39)
        )
        let sut = makeSut(limit: 1000)

        // Act
        try await sut.freeSpace()

        // Assert
        let binaries = try binariesFolder.files(deep: true)
        XCTAssertEqual(binaries.count, 1)
        XCTAssertEqual(binaries[0].path, test_alamofire_content_85d4367.path)

        XCTAssertEqual(loggerBlockInvocations.count, 5)
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.footer == nil })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.metricKey == nil })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.level == .info })
        XCTAssertTrue(loggerBlockInvocations.allSatisfy { $0.output == .all })
        XCTAssertEqual(loggerBlockInvocations[0].header, "Calculating Storage Info")
        XCTAssertEqual(loggerBlockInvocations[1].header, "Finding Candidates")
        XCTAssertEqual(loggerBlockInvocations[2].header, "Selecting Binaries")
        XCTAssertEqual(loggerBlockInvocations[3].header, "Removing files")
        XCTAssertEqual(loggerBlockInvocations[4].header, "Removing build folder")

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 8)
        XCTAssertTrue(logger.logLevelOutputReceivedInvocations.allSatisfy { $0.level == .info })
        XCTAssertTrue(logger.logLevelOutputReceivedInvocations.allSatisfy { $0.output == .all })
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Used: 2 KB (205%)")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[1].text, "Reserved: 2 KB")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[2].text, "Limit: 1 KB")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[3].text, "To Free: 1 KB")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[4].text, "Can\'t add more paths to free space")
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[5].text,
            """
            Folders For Deletion:
            Alamofire.framework
            - \(hash_2b12f8a.path)
            + \(hash_85d4367.path)\n
            """
        )
        XCTAssertEqual(
            logger.logLevelOutputReceivedInvocations[6].text,
            """
            Deleted Empty Folders:
            - \(alamofire_x86_64.path)\n
            """
        )
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[7].text, "Freed: 648 bytes")
    }
}

// MARK: - Utils

private extension String {
    static func generate(count: Int = 12) -> String {
        Array(repeating: NSUUID().uuidString, count: count).joined()
    }
}
