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
        let xcconfigReplacements = localPodXCConfigReplacements
        let xcconfigRegexPattern = localPodXCConfigRegexPattern

        // Act
        let result = try sut.prepareReplacements(forTarget: target)

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].replacements, xcconfigReplacements)
        XCTAssertEqual(result[0].regex.pattern, xcconfigRegexPattern)
        XCTAssertEqual(result[0].filePath, target.xcconfigPaths[0])
        XCTAssertEqual(result[1].replacements, xcconfigReplacements)
        XCTAssertEqual(result[1].regex.pattern, xcconfigRegexPattern)
        XCTAssertEqual(result[1].filePath, target.xcconfigPaths[1])
    }

    func test_prepareReplacements_testsTarget() throws {
        let target = Target.localPodTests
        let xcconfigReplacements = localPodXCConfigReplacements
        let xcconfigRegexPattern = localPodXCConfigRegexPattern

        // Act
        let result = try sut.prepareReplacements(forTarget: target)

        // Assert
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].replacements, xcconfigReplacements)
        XCTAssertEqual(result[0].regex.pattern, xcconfigRegexPattern)
        XCTAssertEqual(result[0].filePath, target.xcconfigPaths[0])
        XCTAssertEqual(result[1].replacements, xcconfigReplacements)
        XCTAssertEqual(result[1].regex.pattern, xcconfigRegexPattern)
        XCTAssertEqual(result[1].filePath, target.xcconfigPaths[1])
        XCTAssertEqual(result[2].replacements, frameworkReplacements)
        XCTAssertEqual(result[2].regex.pattern, frameworksRegexPattern)
        XCTAssertEqual(result[2].filePath, target.frameworksScriptPath)
        XCTAssertEqual(result[3].replacements, resourcesReplacements)
        XCTAssertEqual(result[3].regex.pattern, resourcesRegexPattern)
        XCTAssertEqual(result[3].filePath, target.resourcesScriptPath)
    }

    func test_prepareReplacements_umbrella() throws {
        let target = Target.podsExample
        let xcconfigReplacements = localPodXCConfigReplacements
        let xcconfigRegexPattern = localPodXCConfigRegexPattern

        // Act
        let result = try sut.prepareReplacements(forTarget: target)

        // Assert
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].replacements, xcconfigReplacements)
        XCTAssertEqual(result[0].regex.pattern, xcconfigRegexPattern)
        XCTAssertEqual(result[0].filePath, target.xcconfigPaths[0])
        XCTAssertEqual(result[1].replacements, xcconfigReplacements)
        XCTAssertEqual(result[1].regex.pattern, xcconfigRegexPattern)
        XCTAssertEqual(result[1].filePath, target.xcconfigPaths[1])
        XCTAssertEqual(result[2].replacements, frameworkReplacements)
        XCTAssertEqual(result[2].regex.pattern, frameworksRegexPattern)
        XCTAssertEqual(result[2].filePath, target.frameworksScriptPath)
        XCTAssertEqual(result[3].replacements, resourcesReplacements)
        XCTAssertEqual(result[3].regex.pattern, resourcesRegexPattern)
        XCTAssertEqual(result[3].filePath, target.resourcesScriptPath)
    }
}

private extension SupportFilesPatcherTests {
    private var localPodXCConfigReplacements: [String: String] {
        let prefixKey = "\"${PODS_CONFIGURATION_BUILD_DIR}/"
        let prefixValue = "\"${HOME}/.rugby/bin/"
        let envs = "/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/"
        return [
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
    }

    private var localPodXCConfigRegexPattern: String {
        // swiftlint:disable:next line_length
        #""\$\{PODS_CONFIGURATION_BUILD_DIR\}\/(Moya\/Moya\.framework\/Headers|Moya|Moya\/Moya\.modulemap|Alamofire\/Alamofire\.framework\/Headers|Alamofire|Alamofire\/Alamofire\.modulemap)""#
    }

    private var frameworkReplacements: [String: String] {
        let prefixKey = "\"${BUILT_PRODUCTS_DIR}/"
        let prefixValue = "\"${HOME}/.rugby/bin/"
        let envs = "/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/"
        return [
            "\(prefixKey)Alamofire/Alamofire.framework\"":
                "\(prefixValue)Alamofire\(envs)36ff0bc/Alamofire.framework\"",
            "\(prefixKey)Moya/Moya.framework\"":
                "\(prefixValue)Moya\(envs)badaa58/Moya.framework\""
        ]
    }

    private var frameworksRegexPattern: String {
        #""\$\{BUILT_PRODUCTS_DIR\}\/(Moya\/Moya\.framework|Alamofire\/Alamofire\.framework)""#
    }

    private var resourcesReplacements: [String: String] {
        let prefixValue = "${HOME}/.rugby/bin/"
        let envs = "/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/"
        return [
            "\"${PODS_CONFIGURATION_BUILD_DIR}/LocalPod/LocalPodResources.bundle\"":
                "\"\(prefixValue)LocalPodResources\(envs)17da84b/LocalPodResources.bundle\"",
            "${BUILT_PRODUCTS_DIR}/Moya/Moya.framework/":
                "\(prefixValue)Moya\(envs)badaa58/Moya.framework/",
            "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework/":
                "\(prefixValue)Alamofire\(envs)36ff0bc/Alamofire.framework/"
        ]
    }

    private var resourcesRegexPattern: String {
        // swiftlint:disable:next line_length
        #"("\$\{PODS_CONFIGURATION_BUILD_DIR\}\/(LocalPod\/LocalPodResources\.bundle)"|\$\{BUILT_PRODUCTS_DIR\}\/(Moya\/Moya\.framework\/|Alamofire\/Alamofire\.framework\/))"#
    }
}

private extension Target {
    static var podsExample: IInternalTargetMock {
        let umbrella = IInternalTargetMock()
        umbrella.name = "Pods-Example"
        umbrella.isPodsUmbrella = true
        umbrella.isTests = false
        umbrella.binaryProducts = [
            moyaFramework.product,
            alamofireFramework.product,
            localPodResourcesBundle.product
        ].compactMap()
        let prefixPath = "~/Developer/Rugby/Example/Pods/Target Support Files/Pods-Example"
        umbrella.xcconfigPaths = [
            "\(prefixPath)/Pods-Example.debug.xcconfig",
            "\(prefixPath)/Pods-Example.release.xcconfig"
        ]
        umbrella.frameworksScriptPath = "\(prefixPath)/Pods-Example-frameworks.sh"
        umbrella.resourcesScriptPath = "\(prefixPath)/Pods-Example-resources.sh"
        return umbrella
    }

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

    static var localPodResourcesBundle: IInternalTargetMock {
        let bundle = IInternalTargetMock()
        bundle.name = "LocalPod-LocalPodResources"
        let product = Product(
            name: "LocalPodResources",
            moduleName: nil,
            type: .bundle,
            parentFolderName: "LocalPod"
        )
        let envs = "${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}"
        product.binaryPath = "${HOME}/.rugby/bin/LocalPodResources/\(envs)/17da84b"
        bundle.product = product
        return bundle
    }

    static var localPodTests: IInternalTargetMock {
        let tests = IInternalTargetMock()
        tests.name = "LocalPod-Unit-Tests"
        tests.isPodsUmbrella = false
        tests.isTests = true
        tests.binaryProducts = [
            moyaFramework.product,
            alamofireFramework.product,
            localPodResourcesBundle.product
        ].compactMap()
        let prefixPath = "~/Developer/Rugby/Example/Pods/Target Support Files/LocalPod"
        tests.xcconfigPaths = [
            "\(prefixPath)/LocalPod.unit-tests.debug.xcconfig",
            "\(prefixPath)/LocalPod.unit-tests.release.xcconfig"
        ]
        tests.frameworksScriptPath = "\(prefixPath)/LocalPod-Unit-Tests-frameworks.sh"
        tests.resourcesScriptPath = "\(prefixPath)/LocalPod-Unit-Tests-resources.sh"
        return tests
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
