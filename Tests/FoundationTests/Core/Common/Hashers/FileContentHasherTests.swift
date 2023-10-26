import Fish
@testable import RugbyFoundation
import XCTest

final class FileContentHasherTests: XCTestCase {
    private var sut: FileContentHasher!
    private var foundationHasher: FoundationHasherMock!
    private var workingDirectory: IFolder!

    override func setUp() async throws {
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        let projectFolderURL = testsFolderURL.appendingPathComponent("Example")
        workingDirectory = try Folder.create(at: projectFolderURL.path)

        foundationHasher = FoundationHasherMock()
        sut = FileContentHasher(
            foundationHasher: foundationHasher,
            workingDirectory: workingDirectory
        )
    }

    override func tearDown() {
        super.tearDown()
        foundationHasher = nil
        workingDirectory = nil
        sut = nil
    }
}

extension FileContentHasherTests {
    func test() async throws {
        let podsPath = workingDirectory.path + "/Pods"
        let input = [
            "\(podsPath)/Target Support Files/Keyboard+Layout-framework/Keyboard+LayoutGuide-framework-umbrella.h",
            "\(podsPath)/Keyboard+LayoutGuide/KeyboardLayoutGuide/KeyboardLayoutGuide/Keyboard+LayoutGuide.swift"
        ]
        let expected = [
            "Pods/Keyboard+LayoutGuide/KeyboardLayoutGuide/KeyboardLayoutGuide/Keyboard+LayoutGuide.swift: 1a1f878",
            "Pods/Target Support Files/Keyboard+Layout-framework/Keyboard+LayoutGuide-framework-umbrella.h: 85d4367"
        ]

        let headerContent = "test_header"
        try workingDirectory
            .createFolder(named: "Pods")
            .createFolder(named: "Target Support Files")
            .createFolder(named: "Keyboard+Layout-framework")
            .createFile(named: "Keyboard+LayoutGuide-framework-umbrella.h", contents: headerContent)
        let swiftContent = "test_swift"
        try workingDirectory
            .createFolder(named: "Pods")
            .createFolder(named: "Keyboard+LayoutGuide")
            .createFolder(named: "KeyboardLayoutGuide")
            .createFolder(named: "KeyboardLayoutGuide")
            .createFile(named: "Keyboard+LayoutGuide.swift", contents: swiftContent)

        let results = [
            headerContent.data(using: .utf8): "85d4367",
            swiftContent.data(using: .utf8): "1a1f878"
        ]
        foundationHasher.hashDataClosure = { results[$0] ?? "" }

        // Act
        let result = try await sut.hashContext(paths: input)

        // Assert
        XCTAssertEqual(result, expected)
    }

    func test_relativeToParent() async throws {
        let parent: IFolder! = workingDirectory.parent
        let iosFolder = try workingDirectory.createFolder(named: "ios")
        workingDirectory = iosFolder
        let projectPath = workingDirectory.path
        let input = [
            "\(parent.path)/node_modules/react-native/ReactCommon/jsi/jsi/JSIDynamic.cpp",
            "\(projectPath)/Pods/Target Support Files/React-jsi/React-jsi-dummy.m"
        ]
        let expected = [
            "ios/Pods/Target Support Files/React-jsi/React-jsi-dummy.m: 1a1f878",
            "node_modules/react-native/ReactCommon/jsi/jsi/JSIDynamic.cpp: 85d4367"
        ]

        let cppContent = "test_cpp"
        try parent
            .createFolder(named: "node_modules")
            .createFolder(named: "react-native")
            .createFolder(named: "ReactCommon")
            .createFolder(named: "jsi")
            .createFolder(named: "jsi")
            .createFile(named: "JSIDynamic.cpp", contents: cppContent)
        let mContent = "test_m"
        try workingDirectory
            .createFolder(named: "Pods")
            .createFolder(named: "Target Support Files")
            .createFolder(named: "React-jsi")
            .createFile(named: "React-jsi-dummy.m", contents: mContent)

        let results = [
            cppContent.data(using: .utf8): "85d4367",
            mContent.data(using: .utf8): "1a1f878"
        ]
        foundationHasher.hashDataClosure = { results[$0] ?? "" }

        // Act
        let result = try await sut.hashContext(paths: input)

        // Assert
        XCTAssertEqual(result, expected)
    }
}
