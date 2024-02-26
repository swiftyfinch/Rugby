import Fish
@testable import RugbyFoundation
import XcodeProj
import XCTest

final class XcodeWorkspaceEditorTests: XCTestCase {
    private var sut: IXcodeWorkspaceEditor!
    private var workingDirectory: IFolder!

    override func setUp() async throws {
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        let testsFolder = try Folder.create(at: testsFolderURL.path)
        workingDirectory = try testsFolder.createFolder(named: "workingDirectory")
        sut = XcodeWorkspaceEditor(workingDirectory: workingDirectory)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        workingDirectory = nil
    }
}

extension XcodeWorkspaceEditorTests {
    func test_readProjectPaths_notFound() throws {
        let paths = try sut.readProjectPaths()

        // Assert
        XCTAssertTrue(paths.isEmpty)
    }

    func test_readProjectPaths() throws {
        let example = try workingDirectory.createFolder(named: "Example.xcworkspace")
        try example.createFile(
            named: "contents.xcworkspacedata",
            contents: """
            <?xml version="1.0" encoding="UTF-8"?>
            <Workspace
               version = "1.0">
               <FileRef
                  location = "group:ExampleLibs.xctestplan">
               </FileRef>
               <FileRef
                  location = "group:ExampleFrameworks.xctestplan">
               </FileRef>
               <FileRef
                  location = "group:Example/Example.xcodeproj">
               </FileRef>
               <FileRef
                  location = "group:Pods/Pods.xcodeproj">
               </FileRef>
            </Workspace>
            """
        )

        // Act
        let paths = try sut.readProjectPaths()

        // Assert
        XCTAssertEqual(paths.count, 2)
        XCTAssertEqual(paths, [
            "\(workingDirectory.path)/Example/Example.xcodeproj",
            "\(workingDirectory.path)/Pods/Pods.xcodeproj"
        ])
    }
}
