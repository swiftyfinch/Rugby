import Fish
@testable import RugbyFoundation
import XCTest

final class FileContentHasherTests: XCTestCase {
    private var testDirectory: IFolder!
    private var foundationHasher: FoundationHasherMock!

    override func setUp() async throws {
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        testDirectory = try Folder.create(at: testsFolderURL.path)
        foundationHasher = FoundationHasherMock()
    }

    override func tearDown() {
        super.tearDown()
        testDirectory = nil
        foundationHasher = nil
    }
}

extension FileContentHasherTests {
    func test() async throws {
        let workingDirectory = try testDirectory.createFolder(named: "Example")
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
        let sut = FileContentHasher(
            foundationHasher: foundationHasher,
            workingDirectory: workingDirectory
        )

        // Act
        let result = try await sut.hashContext(paths: input)

        // Assert
        XCTAssertEqual(result, expected)
    }

    func test_relativeToParent() async throws {
        let exampleDirectory = try testDirectory.createFolder(named: "Example")
        let workingDirectory = try exampleDirectory.createFolder(named: "ios")
        let input = [
            "\(exampleDirectory.path)/node_modules/react-native/ReactCommon/jsi/jsi/JSIDynamic.cpp",
            "\(workingDirectory.path)/Pods/Target Support Files/React-jsi/React-jsi-dummy.m"
        ]
        let expected = [
            "Pods/Target Support Files/React-jsi/React-jsi-dummy.m: 1a1f878",
            "node_modules/react-native/ReactCommon/jsi/jsi/JSIDynamic.cpp: 85d4367"
        ]

        let cppContent = "test_cpp"
        try exampleDirectory
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
        let sut = FileContentHasher(
            foundationHasher: foundationHasher,
            workingDirectory: workingDirectory
        )

        // Act
        let result = try await sut.hashContext(paths: input)

        // Assert
        XCTAssertEqual(result, expected)
    }

    func test_relativeToParentOfParent() async throws {
        let exampleDirectory = try testDirectory.createFolder(named: "Example")
        let workingDirectory = try exampleDirectory
            .createFolder(named: "app")
            .createFolder(named: "ios")
        let dependenciesDirectory = try exampleDirectory.createFolder(named: "dependencies")
        let input = [
            "\(dependenciesDirectory.path)/LocalPod/Sources/DummySource.swift",
            "\(exampleDirectory.path)/app/ios/Pods/Alamofire/Source/Request.swift"
        ]
        let expected = [
            "Pods/Alamofire/Source/Request.swift: af22339",
            "dependencies/LocalPod/Sources/DummySource.swift: 85d4367"
        ]

        let dummySourceContent = "test_dummySourceContent"
        try dependenciesDirectory
            .createFolder(named: "LocalPod")
            .createFolder(named: "Sources")
            .createFile(named: "DummySource.swift", contents: dummySourceContent)
        let requestContent = "test_requestContent"
        try workingDirectory
            .createFolder(named: "Pods")
            .createFolder(named: "Alamofire")
            .createFolder(named: "Source")
            .createFile(named: "Request.swift", contents: requestContent)

        let results = [
            dummySourceContent.data(using: .utf8): "85d4367",
            requestContent.data(using: .utf8): "af22339"
        ]
        foundationHasher.hashDataClosure = { results[$0] ?? "" }
        let sut = FileContentHasher(
            foundationHasher: foundationHasher,
            workingDirectory: workingDirectory
        )

        // Act
        let result = try await sut.hashContext(paths: input)

        // Assert
        XCTAssertEqual(result, expected)
    }
}
