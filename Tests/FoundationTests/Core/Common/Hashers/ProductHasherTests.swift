@testable import RugbyFoundation
import XCTest

final class ProductHasherTests: XCTestCase {
    private var sut: IProductHasher!

    override func setUp() {
        super.setUp()
        sut = ProductHasher()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

extension ProductHasherTests {
    func test_framework() {
        let product = Product(
            name: "KeyboardLayoutGuide",
            moduleName: "KeyboardLayoutGuide",
            type: .framework,
            parentFolderName: "Keyboard+LayoutGuide-framework"
        )

        // Act
        let hashContext = sut.hashContext(product)

        // Assert
        XCTAssertEqual(
            hashContext,
            [
                "parentFolderName": "Keyboard+LayoutGuide-framework",
                "name": "KeyboardLayoutGuide",
                "type": "com.apple.product-type.framework"
            ]
        )
    }

    func test_library() {
        let product = Product(
            name: "Keyboard+LayoutGuide-library",
            moduleName: "KeyboardLayoutGuide",
            type: .staticLibrary,
            parentFolderName: "Keyboard+LayoutGuide-library"
        )

        // Act
        let hashContext = sut.hashContext(product)

        // Assert
        XCTAssertEqual(
            hashContext,
            [
                "parentFolderName": "Keyboard+LayoutGuide-library",
                "name": "Keyboard+LayoutGuide-library",
                "type": "com.apple.product-type.library.static"
            ]
        )
    }

    func test_bundle() {
        let product = Product(
            name: "LocalPodResources",
            moduleName: nil,
            type: .bundle,
            parentFolderName: "LocalPod-framework"
        )

        // Act
        let hashContext = sut.hashContext(product)

        // Assert
        XCTAssertEqual(
            hashContext,
            [
                "parentFolderName": "LocalPod-framework",
                "name": "LocalPodResources",
                "type": "com.apple.product-type.bundle"
            ]
        )
    }
}
