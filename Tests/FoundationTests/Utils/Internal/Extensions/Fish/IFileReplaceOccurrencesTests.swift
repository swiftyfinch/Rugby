import Fish
@testable import RugbyFoundation
import XCTest

final class IFileReplaceOccurrencesTests: XCTestCase {
    private var testsFolder: IFolder!

    override func setUp() async throws {
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        testsFolder = try Folder.create(at: testsFolderURL.path)
    }

    override func tearDown() {
        super.tearDown()
        testsFolder = nil
    }
}

extension IFileReplaceOccurrencesTests {
    func test_replaceOccurrences() throws {
        let testFile = try testsFolder.createFile(
            named: "test",
            contents: "Cache CocoaPods for faster rebuild and indexing xCode project."
        )

        // Act
        try testFile.replaceOccurrences(of: "xCode", with: "Xcode")

        // Assert
        try XCTAssertEqual(
            testFile.read(),
            "Cache CocoaPods for faster rebuild and indexing Xcode project."
        )
    }

    func test_replaceOccurrences_delete() throws {
        let testFile = try testsFolder.createFile(
            named: "test",
            contents: "One two three one four one five"
        )

        // Act
        try testFile.replaceOccurrences(of: "one ")

        // Assert
        try XCTAssertEqual(testFile.read(), "One two three four five")
    }
}
