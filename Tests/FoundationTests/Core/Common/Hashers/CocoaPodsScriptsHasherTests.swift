import Fish
@testable import RugbyFoundation
import XCTest

final class CocoaPodsScriptsHasherTests: XCTestCase {
    private var sut: ICocoaPodsScriptsHasher!
    private var fileContentHasher: IFileContentHasherMock!
    private var fishSharedStorage: IFilesManagerMock!

    override func setUp() {
        super.setUp()
        fishSharedStorage = IFilesManagerMock()
        let backupFishSharedStorage = Fish.sharedStorage
        Fish.sharedStorage = fishSharedStorage
        addTeardownBlock {
            Fish.sharedStorage = backupFishSharedStorage
        }

        fileContentHasher = IFileContentHasherMock()
        sut = CocoaPodsScriptsHasher(fileContentHasher: fileContentHasher)
    }

    override func tearDown() {
        super.tearDown()
        fishSharedStorage = nil
        fileContentHasher = nil
        sut = nil
    }
}

// swiftlint:disable line_length

extension CocoaPodsScriptsHasherTests {
    func test_notFound() async throws {
        let target = IInternalTargetMock()
        target.resourcesScriptPath = "/Users/swiftyfinch/Developer/Example/Pods/Target Support Files/LocalPod-framework/LocalPod-framework-resources.sh"
        target.frameworksScriptPath = "/Users/swiftyfinch/Developer/Example/Pods/Target Support Files/LocalPod-framework/LocalPod-framework-frameworks.sh"
        fishSharedStorage.isItemExistAtReturnValue = false
        fileContentHasher.hashContextPathsReturnValue = []

        // Act
        let hashContext = try await sut.hashContext(target)

        // Assert
        XCTAssertTrue(hashContext.isEmpty)
        XCTAssertEqual(fileContentHasher.hashContextPathsCallsCount, 1)
        XCTAssertEqual(fileContentHasher.hashContextPathsReceivedPaths?.count, 0)
    }

    func test_found() async throws {
        let resourcesScriptPath = "/Users/swiftyfinch/Developer/Example/Pods/Target Support Files/LocalPod-framework/LocalPod-framework-resources.sh"
        let frameworksScriptPath = "/Users/swiftyfinch/Developer/Example/Pods/Target Support Files/LocalPod-framework/LocalPod-framework-frameworks.sh"
        let target = IInternalTargetMock()
        target.resourcesScriptPath = resourcesScriptPath
        target.frameworksScriptPath = frameworksScriptPath
        fishSharedStorage.isItemExistAtReturnValue = true
        let expectedHashContext = [
            "Pods/Target Support Files/LocalPod-framework/LocalPod-framework-resources.sh: 139bece",
            "Pods/Target Support Files/LocalPod-framework/LocalPod-framework-frameworks.sh: dbe4415"
        ]
        fileContentHasher.hashContextPathsReturnValue = expectedHashContext

        // Act
        let hashContext = try await sut.hashContext(target)

        // Assert
        XCTAssertEqual(hashContext, expectedHashContext)
        XCTAssertEqual(fileContentHasher.hashContextPathsCallsCount, 1)
        XCTAssertEqual(
            fileContentHasher.hashContextPathsReceivedPaths,
            [resourcesScriptPath, frameworksScriptPath]
        )
    }
}

// swiftlint:enable line_length
