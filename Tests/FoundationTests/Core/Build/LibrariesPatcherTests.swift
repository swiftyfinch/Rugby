import Fish
@testable import RugbyFoundation
import XCTest

final class LibrariesPatcherTests: XCTestCase {
    private var sut: LibrariesPatcher!
    private var logger: ILoggerMock!
    private var fishSharedStorage: IFilesManagerMock!

    override func setUp() {
        super.setUp()
        logger = ILoggerMock()
        sut = LibrariesPatcher(logger: logger)
        fishSharedStorage = IFilesManagerMock()
        let backupFishSharedStorage = Fish.sharedStorage
        Fish.sharedStorage = fishSharedStorage
        addTeardownBlock {
            Fish.sharedStorage = backupFishSharedStorage
        }
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        sut = nil
        fishSharedStorage = nil
    }
}

extension LibrariesPatcherTests {
    func test_basic() async throws {
        let fileMock = IFileMock()
        fileMock.readReturnValue = """
        PODS_PODFILE_DIR_PATH = ${SRCROOT}/..
        PODS_ROOT = ${SRCROOT}/../Pods
        PODS_XCFRAMEWORKS_BUILD_DIR = $(PODS_CONFIGURATION_BUILD_DIR)/XCFrameworkIntermediates
        CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = NO
        """
        fishSharedStorage.fileAtReturnValue = fileMock

        let library = IInternalTargetMock()
        library.name = "Library"
        library.underlyingUuid = "test_library_id"
        library.product = Product(
            name: "Library",
            moduleName: nil,
            type: .staticLibrary,
            parentFolderName: nil
        )
        library.buildPhases = [
            .init(
                name: "[CP] Copy XCFrameworks",
                type: .runScript
            )
        ]
        library.xcconfigPaths = [
            // swiftlint:disable:next line_length
            "/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Target Support Files/Realm-library/Realm-library.debug.xcconfig"
        ]
        let framework = IInternalTargetMock()
        framework.name = "Framework"
        framework.underlyingUuid = "test_framework_id"
        framework.product = Product(
            name: "Framework",
            moduleName: nil,
            type: .framework,
            parentFolderName: nil
        )
        let libraryWithoutPhase = IInternalTargetMock()
        libraryWithoutPhase.name = "LibraryWithoutPhase"
        libraryWithoutPhase.underlyingUuid = "test_libraryWithoutPhase_id"
        libraryWithoutPhase.product = Product(
            name: "LibraryWithoutPhase",
            moduleName: nil,
            type: .staticLibrary,
            parentFolderName: nil
        )

        // Act
        try await sut.patch([
            library.uuid: library,
            framework.uuid: framework,
            libraryWithoutPhase.uuid: libraryWithoutPhase
        ])

        // Assert
        XCTAssertEqual(
            fishSharedStorage.fileAtReceivedPath,
            // swiftlint:disable:next line_length
            "/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Target Support Files/Realm-library/Realm-library.debug.xcconfig"
        )
        XCTAssertEqual(fileMock.writeCallsCount, 1)
        XCTAssertEqual(
            fileMock.writeReceivedText,
            """
            PODS_PODFILE_DIR_PATH = ${SRCROOT}/..
            PODS_ROOT = ${SRCROOT}/../Pods
            PODS_XCFRAMEWORKS_BUILD_DIR = ${PODS_CONFIGURATION_BUILD_DIR}/${PRODUCT_NAME}
            CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = NO
            """
        )
    }
}
