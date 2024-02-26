import Fish
@testable import RugbyFoundation
import XCTest

final class CleanerTests: XCTestCase {
    private var sut: ICleaner!
    private var sharedRugbyFolder: IFolder!
    private var buildFolder: IFolder!

    override func setUp() async throws {
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        let testsFolder = try Folder.create(at: testsFolderURL.path)
        buildFolder = try testsFolder.createFolder(named: ".rugby").createFolder(named: "build")
        sharedRugbyFolder = try testsFolder.createFolder(named: ".rugby_shared")
        sut = Cleaner(
            sharedBinariesPath: sharedRugbyFolder.path,
            buildFolderPath: buildFolder.path
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        sharedRugbyFolder = nil
        buildFolder = nil
    }
}

extension CleanerTests {
    func test_deleteSharedBinaries() async throws {
        try sharedRugbyFolder.createFolder(named: "Alamofire")
            .createFile(named: "Content", contents: "test_alamofire_content")
        try sharedRugbyFolder.createFolder(named: "SnapKit")
            .createFile(named: "Content", contents: "test_snapkit_content")
        let moya = try sharedRugbyFolder.createFolder(named: "Moya")
        let moyaContent = try moya.createFile(named: "Content", contents: "test_moya_content")
        let build = try buildFolder.createFile(named: "Content", contents: "test_build_content")

        // Act
        try await sut.deleteSharedBinaries(names: ["Alamofire", "SnapKit", "Realm"])

        // Assert
        let sharedFolders: [IItem] = try sharedRugbyFolder.folders(deep: true) + sharedRugbyFolder.files(deep: true)
        XCTAssertEqual(sharedFolders.count, 2)
        XCTAssertTrue(sharedFolders.map(\.path).contains(moya.path))
        XCTAssertTrue(sharedFolders.map(\.path).contains(moyaContent.path))
        let buildFolders: [IItem] = try buildFolder.folders(deep: true) + buildFolder.files(deep: true)
        XCTAssertEqual(buildFolders.count, 1)
        XCTAssertTrue(buildFolders.map(\.path).contains(build.path))
    }

    func test_deleteAllSharedBinaries() async throws {
        try sharedRugbyFolder.createFolder(named: "Alamofire").createFolder(named: "Content")
        try sharedRugbyFolder.createFolder(named: "SnapKit").createFolder(named: "Content")
        try sharedRugbyFolder.createFolder(named: "Moya").createFolder(named: "Content")
        let build = try buildFolder.createFolder(named: "Content")

        // Act
        try await sut.deleteAllSharedBinaries()

        // Assert
        let sharedFolders = try sharedRugbyFolder.folders(deep: true)
        XCTAssertTrue(sharedFolders.isEmpty)
        let buildFolders = try buildFolder.folders(deep: true)
        XCTAssertEqual(buildFolders.count, 1)
        XCTAssertTrue(buildFolders.map(\.path).contains(build.path))
    }

    func test_deleteBuildFolder() async throws {
        try buildFolder.createFolder(named: "Content")
        let moya = try sharedRugbyFolder.createFolder(named: "Moya")
        let moyaContent = try moya.createFolder(named: "Content")

        // Act
        try await sut.deleteBuildFolder()

        // Assert
        let sharedFolders = try sharedRugbyFolder.folders(deep: true)
        XCTAssertEqual(sharedFolders.count, 2)
        XCTAssertTrue(sharedFolders.map(\.path).contains(moya.path))
        XCTAssertTrue(sharedFolders.map(\.path).contains(moyaContent.path))
        let buildFolders = try buildFolder.folders(deep: true)
        XCTAssertTrue(buildFolders.isEmpty)
    }
}
