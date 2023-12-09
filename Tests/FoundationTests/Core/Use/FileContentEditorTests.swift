import Fish
@testable import RugbyFoundation
import XCTest

final class FileContentEditorTests: XCTestCase {
    private var sut: IFileContentEditor!
    private var fishSharedStorage: IFilesManagerMock!

    override func setUpWithError() throws {
        fishSharedStorage = IFilesManagerMock()
        let backupFishSharedStorage = Fish.sharedStorage
        Fish.sharedStorage = fishSharedStorage
        addTeardownBlock {
            Fish.sharedStorage = backupFishSharedStorage
        }
        sut = FileContentEditor()
    }

    override func tearDownWithError() throws {
        sut = nil
        fishSharedStorage = nil
    }
}

extension FileContentEditorTests {
    func test_replace_pathFormat() throws {
        var newContent = ""
        let file = IFileMock()
        file.writeClosure = { newContent = $0 }
        // swiftlint:disable line_length
        file.readClosure = {
            """
            FRAMEWORK_SEARCH_PATH = $(Inherited) "${PODS_CONFIGURATION_BUILD_DIR}/Realm-library"
            HEADER_SEARCH_PATH = $(Inherited) ${PODS_CONFIGURATION_BUILD_DIR}/Realm-library/libRealm-library.a/Headers '${PODS_CONFIGURATION_BUILD_DIR}/Moya/Moya.framework/Headers'
            """
        }
        let replacements = [
            "${PODS_CONFIGURATION_BUILD_DIR}/Realm-library":
                "${HOME}/.rugby/bin/Realm-library/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/d2d48c5",
            "${PODS_CONFIGURATION_BUILD_DIR}/Realm-library/libRealm-library.a/Headers":
                "${HOME}/.rugby/bin/Realm-library/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/d2d48c5/libRealm-library.a/Headers",
            "${PODS_CONFIGURATION_BUILD_DIR}/Moya/Moya.framework/Headers":
                "${HOME}/.rugby/bin/Moya/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/badaa58/Moya.framework/Headers"
        ]
        let joinedReplacementStr = #"(\$\{PODS_CONFIGURATION_BUILD_DIR\}/Realm-library|\$\{PODS_CONFIGURATION_BUILD_DIR\}/Realm-library/libRealm-library\.a/Headers|\$\{PODS_CONFIGURATION_BUILD_DIR\}/Moya/Moya\.framework/Headers)"#
        // Ensured that the validation method here matches the matching approach in SupportFilesPatcher.
        let regexPattern = try "\(ReplacementBoundary.prefix)\(joinedReplacementStr)\(ReplacementBoundary.suffix)".regex()
        let expectedNewContent = """
        FRAMEWORK_SEARCH_PATH = $(Inherited) "${HOME}/.rugby/bin/Realm-library/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/d2d48c5"
        HEADER_SEARCH_PATH = $(Inherited) ${HOME}/.rugby/bin/Realm-library/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/d2d48c5/libRealm-library.a/Headers '${HOME}/.rugby/bin/Moya/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/badaa58/Moya.framework/Headers'
        """
        // swiftlint:enable line_length
        fishSharedStorage.isItemExistAtClosure = { _ in true }
        fishSharedStorage.fileAtClosure = { _ in file }

        // Act
        try sut.replace(replacements, regex: regexPattern, filePath: "/test/path")

        // Assert
        XCTAssertEqual(newContent, expectedNewContent)
    }
}
