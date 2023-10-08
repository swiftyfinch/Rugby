@testable import RugbyFoundation
import XCTest

final class SupportFilesPatcherTests: XCTestCase {
    private var sut: ISupportFilesPatcher!

    override func setUp() {
        super.setUp()
        sut = SupportFilesPatcher()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

extension SupportFilesPatcherTests {
    func test_prepareReplacements_framework() throws {
        let target = Target.localPodFramework
        let prefixKey = "\"${PODS_CONFIGURATION_BUILD_DIR}/"
        let prefixValue = "\"${HOME}/.rugby/bin/"
        let envs = "/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/"
        let expectedReplacements = [
            "\(prefixKey)Alamofire\"":
                "\(prefixValue)Alamofire\(envs)36ff0bc\"",
            "\(prefixKey)Moya/Moya.modulemap\"":
                "\(prefixValue)Moya\(envs)badaa58/Moya.modulemap\"",
            "\(prefixKey)Alamofire/Alamofire.framework/Headers\"":
                "\(prefixValue)Alamofire\(envs)36ff0bc/Alamofire.framework/Headers\"",
            "\(prefixKey)Alamofire/Alamofire.modulemap\"":
                "\(prefixValue)Alamofire\(envs)36ff0bc/Alamofire.modulemap\"",
            "\(prefixKey)Moya/Moya.framework/Headers\"":
                "\(prefixValue)Moya\(envs)badaa58/Moya.framework/Headers\"",
            "\(prefixKey)Moya\"":
                "\(prefixValue)Moya\(envs)badaa58\""
        ]
        // swiftlint:disable:next line_length
        let expectedPattern = #""\$\{PODS_CONFIGURATION_BUILD_DIR\}\/(Moya\/Moya\.framework\/Headers|Moya|Moya\/Moya\.modulemap|Alamofire\/Alamofire\.framework\/Headers|Alamofire|Alamofire\/Alamofire\.modulemap)""#

        // Act
        let result = try sut.prepareReplacements(forTarget: target)

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].replacements, expectedReplacements)
        XCTAssertEqual(result[0].regex.pattern, expectedPattern)
        XCTAssertEqual(result[0].filePath, target.xcconfigPaths[0])
        XCTAssertEqual(result[1].replacements, expectedReplacements)
        XCTAssertEqual(result[1].regex.pattern, expectedPattern)
        XCTAssertEqual(result[1].filePath, target.xcconfigPaths[1])
    }
}

private extension Target {
    static var localPodFramework: IInternalTargetMock {
        let moyaFramework = Target.moyaFramework
        let alamofireFramework = Target.alamofireFramework
        let localPodFramework = IInternalTargetMock()
        localPodFramework.name = "LocalPod"
        localPodFramework.isPodsUmbrella = false
        localPodFramework.isTests = false
        localPodFramework.binaryProducts = [
            moyaFramework.product,
            alamofireFramework.product
        ].compactMap()
        localPodFramework.xcconfigPaths = [
            "~/Developer/Rugby/Example/Pods/Target Support Files/LocalPod/LocalPod.release.xcconfig",
            "~/Developer/Rugby/Example/Pods/Target Support Files/LocalPod/LocalPod.debug.xcconfig"
        ]
        return localPodFramework
    }

    static var moyaFramework: IInternalTargetMock {
        let moya = IInternalTargetMock()
        moya.name = "Moya"
        let product = Product(
            name: "Moya",
            moduleName: "Moya",
            type: .framework,
            parentFolderName: "Moya"
        )
        product.binaryPath = "${HOME}/.rugby/bin/Moya/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/badaa58"
        moya.product = product
        return moya
    }

    static var alamofireFramework: IInternalTargetMock {
        let alamofire = IInternalTargetMock()
        alamofire.name = "Alamofire"
        let product = Product(
            name: "Alamofire",
            moduleName: "Alamofire",
            type: .framework,
            parentFolderName: "Alamofire"
        )
        product.binaryPath = "${HOME}/.rugby/bin/Alamofire/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/36ff0bc"
        alamofire.product = product
        return alamofire
    }
}
