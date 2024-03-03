import Fish
@testable import RugbyFoundation
import XCTest

final class CleanerTests: XCTestCase {
    private var sut: ICleaner!
    private var sharedBinariesFolder: IFolder!
    private var buildFolder: IFolder!
    private var sharedTestsFolder: IFolder!

    override func setUp() async throws {
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        let testsFolder = try Folder.create(at: testsFolderURL.path)
        buildFolder = try testsFolder.createFolder(named: ".rugby").createFolder(named: "build")
        let sharedRugbyFolder = try testsFolder.createFolder(named: ".rugby_shared")
        sharedBinariesFolder = try sharedRugbyFolder.createFolder(named: "bin")
        sharedTestsFolder = try sharedRugbyFolder.createFolder(named: "tests")
        sut = Cleaner(
            sharedBinariesPath: sharedBinariesFolder.path,
            buildFolderPath: buildFolder.path,
            testsFolderPath: sharedTestsFolder.path
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        sharedBinariesFolder = nil
        buildFolder = nil
        sharedTestsFolder = nil
    }
}

extension CleanerTests {
    func test_deleteSharedBinaries() async throws {
        try sharedBinariesFolder.createFolder(named: "Alamofire")
            .createFile(named: "Content", contents: "test_alamofire_content")
        try sharedBinariesFolder.createFolder(named: "SnapKit")
            .createFile(named: "Content", contents: "test_snapkit_content")
        let moya = try sharedBinariesFolder.createFolder(named: "Moya")
        let moyaContent = try moya.createFile(named: "Content", contents: "test_moya_content")
        let build = try buildFolder.createFile(named: "Content", contents: "test_build_content")

        // Act
        try await sut.deleteSharedBinaries(names: ["Alamofire", "SnapKit", "Realm"])

        // Assert
        let sharedFolders: [IItem] = try [
            sharedBinariesFolder.folders(deep: true) as [IItem],
            sharedBinariesFolder.files(deep: true) as [IItem]
        ].flatMap { $0 }
        XCTAssertEqual(sharedFolders.count, 2)
        XCTAssertTrue(sharedFolders.map(\.path).contains(moya.path))
        XCTAssertTrue(sharedFolders.map(\.path).contains(moyaContent.path))
        let buildFolders: [IItem] = try buildFolder.folders(deep: true) + buildFolder.files(deep: true)
        XCTAssertEqual(buildFolders.count, 1)
        XCTAssertTrue(buildFolders.map(\.path).contains(build.path))
    }

    func test_deleteAllSharedBinaries() async throws {
        try sharedBinariesFolder.createFolder(named: "Alamofire").createFolder(named: "Content")
        try sharedBinariesFolder.createFolder(named: "SnapKit").createFolder(named: "Content")
        try sharedBinariesFolder.createFolder(named: "Moya").createFolder(named: "Content")
        let build = try buildFolder.createFolder(named: "Content")

        // Act
        try await sut.deleteAllSharedBinaries()

        // Assert
        let sharedFolders = try sharedBinariesFolder.folders(deep: true)
        XCTAssertTrue(sharedFolders.isEmpty)
        let buildFolders = try buildFolder.folders(deep: true)
        XCTAssertEqual(buildFolders.count, 1)
        XCTAssertTrue(buildFolders.map(\.path).contains(build.path))
    }

    func test_deleteBuildFolder() async throws {
        try buildFolder.createFolder(named: "Content")
        let moya = try sharedBinariesFolder.createFolder(named: "Moya")
        let moyaContent = try moya.createFolder(named: "Content")

        // Act
        try await sut.deleteBuildFolder()

        // Assert
        let sharedFolders = try sharedBinariesFolder.folders(deep: true)
        XCTAssertEqual(sharedFolders.count, 2)
        XCTAssertTrue(sharedFolders.map(\.path).contains(moya.path))
        XCTAssertTrue(sharedFolders.map(\.path).contains(moyaContent.path))
        let buildFolders = try buildFolder.folders(deep: true)
        XCTAssertTrue(buildFolders.isEmpty)
    }

    func test_deleteTestsFolder() async throws {
        try sharedTestsFolder
            .createFolder(named: "LocalPod-Unit-Tests/Debug-iphonesimulator-arm64/fe01fae")
            .createFile(named: "fe01fae.yml")
        try sharedTestsFolder
            .createFolder(named: "LocalPod-Unit-ResourceBundleTests/Debug-iphonesimulator-arm64/f0d6226")
            .createFile(named: "f0d6226.yml")

        // Act
        try await sut.deleteTestsFolder()

        // Assert
        let testsFolders = try sharedTestsFolder.folders(deep: false)
        XCTAssertTrue(testsFolders.isEmpty)
    }
}
