import Fish
@testable import RugbyFoundation
import XCTest

final class TestsStorageTests: XCTestCase {
    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!

    private var sharedFolder: IFolder!
    private var binariesStorage: IBinariesStorageMock!
    private var sut: ITestsStorage!

    override func setUp() async throws {
        try await super.setUp()
        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }

        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        let testsFolder = try Folder.create(at: testsFolderURL.path)
        sharedFolder = try testsFolder.createFolder(named: "shared")

        binariesStorage = IBinariesStorageMock()
        sut = TestsStorage(
            logger: logger,
            binariesStorage: binariesStorage,
            sharedPath: sharedFolder.path
        )
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        loggerBlockInvocations = nil
        sharedFolder = nil
        binariesStorage = nil
        sut = nil
    }
}

extension TestsStorageTests {
    func test_saveTests() async throws {
        let buildOptions = XcodeBuildOptions(
            sdk: .sim,
            config: "Debug",
            arch: "arm64",
            xcargs: ["COMPILER_INDEX_STORE_ENABLE=NO", "SWIFT_COMPILATION_MODE=wholemodule"],
            resultBundlePath: nil
        )
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.underlyingUuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.underlyingName = "LocalPod-framework-Unit-Tests"
        localPodFrameworkUnitTests.hash = "b64104e"
        localPodFrameworkUnitTests.hashContext = "b64104e_hashContext"
        let localPodLibraryUnitTests = IInternalTargetMock()
        localPodLibraryUnitTests.underlyingUuid = "localPodLibraryUnitTests_uuid"
        localPodLibraryUnitTests.underlyingName = "LocalPod-library-Unit-Tests"
        localPodLibraryUnitTests.hash = "1417ca1"
        localPodLibraryUnitTests.hashContext = "1417ca1_hashContext"
        let targets: TargetsMap = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodLibraryUnitTests.uuid: localPodLibraryUnitTests
        ]
        let relativePathb64104e = "LocalPod-framework-Unit-Tests/Debug-iphonesimulator-arm64/b64104e"
        let relativePath1417ca1 = "LocalPod-library-Unit-Tests/Debug-iphonesimulator-arm64/1417ca1"
        binariesStorage.binaryRelativePathBuildOptionsClosure = { target, _ in
            switch target.name {
            case localPodFrameworkUnitTests.name: return relativePathb64104e
            case localPodLibraryUnitTests.name: return relativePath1417ca1
            default: fatalError()
            }
        }

        // Act
        try await sut.saveTests(of: targets, buildOptions: buildOptions)

        // Assert
        XCTAssertEqual(binariesStorage.binaryRelativePathBuildOptionsCallsCount, 2)
        XCTAssertTrue(File.isExist(at: sharedFolder.subpath("\(relativePathb64104e)/b64104e.yml")))
        try XCTAssertEqual(sharedFolder.file(named: "\(relativePathb64104e)/b64104e.yml").read(),
                           localPodFrameworkUnitTests.hashContext)
        XCTAssertTrue(File.isExist(at: sharedFolder.subpath("\(relativePath1417ca1)/1417ca1.yml")))
        try XCTAssertEqual(sharedFolder.file(named: "\(relativePath1417ca1)/1417ca1.yml").read(),
                           localPodLibraryUnitTests.hashContext)
    }

    func test_findMissingTests() async throws {
        let buildOptions = XcodeBuildOptions(
            sdk: .sim,
            config: "Debug",
            arch: "arm64",
            xcargs: ["COMPILER_INDEX_STORE_ENABLE=NO", "SWIFT_COMPILATION_MODE=wholemodule"],
            resultBundlePath: nil
        )
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.uuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.name = "LocalPod-framework-Unit-Tests"
        localPodFrameworkUnitTests.hash = "b64104e"
        localPodFrameworkUnitTests.hashContext = "b64104e_hashContext"
        let localPodLibraryUnitTests = IInternalTargetMock()
        localPodLibraryUnitTests.uuid = "localPodLibraryUnitTests_uuid"
        localPodLibraryUnitTests.name = "LocalPod-library-Unit-Tests"
        localPodLibraryUnitTests.hash = "1417ca1"
        localPodLibraryUnitTests.hashContext = "1417ca1_hashContext"
        let targets: TargetsMap = [
            localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests,
            localPodLibraryUnitTests.uuid: localPodLibraryUnitTests
        ]
        let relativePathb64104e = "LocalPod-framework-Unit-Tests/Debug-iphonesimulator-arm64/b64104e"
        let relativePath1417ca1 = "LocalPod-library-Unit-Tests/Debug-iphonesimulator-arm64/1417ca1"
        binariesStorage.binaryRelativePathBuildOptionsClosure = { target, _ in
            switch target.name {
            case localPodFrameworkUnitTests.name: return relativePathb64104e
            case localPodLibraryUnitTests.name: return relativePath1417ca1
            default: fatalError()
            }
        }
        try sharedFolder.createFolder(named: relativePathb64104e).createFile(named: "b64104e.yml")

        // Act
        let foundTargets = try await sut.findMissingTests(of: targets, buildOptions: buildOptions)

        // Assert
        XCTAssertEqual(foundTargets.count, 1)
        XCTAssertEqual(foundTargets[0].uuid, localPodLibraryUnitTests.uuid)
    }
}
