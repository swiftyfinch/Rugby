@testable import RugbyFoundation
import XcodeProj
import XCTest

final class PBXTargetProductTests: XCTestCase {
    func test_constructProduct() throws {
        let target = PBXTarget(name: "Keyboard+LayoutGuide", productType: .framework)
        let buildSettings: BuildSettings = [
            "PRODUCT_NAME": "Keyboard+LayoutGuide",
            "CONFIGURATION_BUILD_DIR": "${PODS_CONFIGURATION_BUILD_DIR}/Keyboard+LayoutGuide",
            "PRODUCT_MODULE_NAME": "KeyboardLayoutGuide"
        ]

        // Act
        let product = try target.constructProduct(buildSettings)

        // Assert
        XCTAssertEqual(product?.name, "Keyboard+LayoutGuide")
        XCTAssertEqual(product?.moduleName, "KeyboardLayoutGuide")
        XCTAssertEqual(product?.type, .framework)
        XCTAssertEqual(product?.fileName, "Keyboard+LayoutGuide.framework")
        XCTAssertEqual(product?.nameWithParent, "Keyboard+LayoutGuide/Keyboard+LayoutGuide.framework")
        XCTAssertEqual(product?.parentFolderName, "Keyboard+LayoutGuide")
    }
}
