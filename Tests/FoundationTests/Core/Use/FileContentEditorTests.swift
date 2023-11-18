import XCTest
@testable import RugbyFoundation

final class FileContentEditorTests: XCTestCase {
    private var sut: FileContentEditor!
    
    override func setUpWithError() throws {
        sut = FileContentEditor()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
}

extension FileContentEditorTests {
    func test_replace_pathFormat() throws {
        var newContent = ""
        let file = IFileMock()
        file.writeClosure = { newContent = $0 }
        file.readClosure = {
        """
FRAMEWORK_SEARCH_PATH = $(Inherited) "${PODS_CONFIGURATION_BUILD_DIR}/Realm-library"
HEADER_SEARCH_PATH = $(Inherited) ${PODS_CONFIGURATION_BUILD_DIR}/Realm-library/libRealm-library.a/Headers '${PODS_CONFIGURATION_BUILD_DIR}/Moya/Moya.framework/Headers'
"""
        }
        let replacements = [
            "${PODS_CONFIGURATION_BUILD_DIR}/Realm-library": "${HOME}/.rugby/bin/Realm-library/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/d2d48c5",
            "${PODS_CONFIGURATION_BUILD_DIR}/Realm-library/libRealm-library.a/Headers": "${HOME}/.rugby/bin/Realm-library/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/d2d48c5/libRealm-library.a/Headers",
            "${PODS_CONFIGURATION_BUILD_DIR}/Moya/Moya.framework/Headers": "${HOME}/.rugby/bin/Moya/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/badaa58/Moya.framework/Headers"
        ]
        let regexPattern = try #"(\$\{PODS_CONFIGURATION_BUILD_DIR\}/Realm-library|\$\{PODS_CONFIGURATION_BUILD_DIR\}/Realm-library/libRealm-library\.a/Headers|\$\{PODS_CONFIGURATION_BUILD_DIR\}/Moya/Moya\.framework/Headers)\b"#.regex()
        
        // Act
        try sut.replace(replacements, regex: regexPattern, file: file)
        
        // Assert
        XCTAssertEqual(newContent, """
FRAMEWORK_SEARCH_PATH = $(Inherited) "${HOME}/.rugby/bin/Realm-library/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/d2d48c5"
HEADER_SEARCH_PATH = $(Inherited) ${HOME}/.rugby/bin/Realm-library/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/d2d48c5/libRealm-library.a/Headers '${HOME}/.rugby/bin/Moya/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/badaa58/Moya.framework/Headers'
""")
    }
}
