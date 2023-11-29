@testable import RugbyFoundation
import XCTest

final class ConfigurationsHasherTests: XCTestCase {
    private var sut: IConfigurationsHasher!

    override func setUp() {
        super.setUp()
        sut = ConfigurationsHasher(excludeKeys: ["RUGBY_HAS_BACKUP"])
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

extension ConfigurationsHasherTests {
    func test() throws {
        let target = IInternalTargetMock()
        target.configurations = [
            "Debug": Configuration(
                name: "Debug",
                buildSettings: [
                    "PRODUCT_MODULE_NAME": "KeyboardLayoutGuide",
                    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
            ),
            "Release": Configuration(
                name: "Release",
                buildSettings: [
                    "PRODUCT_MODULE_NAME": "KeyboardLayoutGuide",
                    "SWIFT_OPTIMIZATION_LEVEL": "-O",
                    "SWIFT_COMPILATION_MODE": "wholemodule"
                ]
            )
        ]

        // Act
        let anyHashContext = try sut.hashContext(target)

        // Assert
        let hashContext = try XCTUnwrap(anyHashContext as? [[String: Any]])
        XCTAssertEqual(hashContext.count, 3)
        XCTAssertEqual(hashContext[0]["name"] as? String, "_Common")
        XCTAssertEqual(hashContext[0]["buildSettings"] as? [String: String],
                       ["PRODUCT_MODULE_NAME": "KeyboardLayoutGuide"])
        XCTAssertEqual(hashContext[1]["name"] as? String, "Debug")
        XCTAssertEqual(hashContext[1]["buildSettings"] as? [String: String],
                       ["ONLY_ACTIVE_ARCH": "YES", "SWIFT_OPTIMIZATION_LEVEL": "-Onone"])
        XCTAssertEqual(hashContext[2]["name"] as? String, "Release")
        XCTAssertEqual(hashContext[2]["buildSettings"] as? [String: String],
                       ["SWIFT_OPTIMIZATION_LEVEL": "-O", "SWIFT_COMPILATION_MODE": "wholemodule"])
    }
}
