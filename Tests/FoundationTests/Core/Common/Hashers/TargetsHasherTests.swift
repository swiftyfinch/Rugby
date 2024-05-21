@testable import RugbyFoundation
import XCTest

final class TargetsHasherTests: XCTestCase {
    private var sut: ITargetsHasher!
    private var foundationHasher: FoundationHasherMock!
    private var swiftVersionProvider: ISwiftVersionProviderMock!
    private var xcodeCLTVersionProvider: IXcodeCLTVersionProviderMock!
    private var buildPhaseHasher: IBuildPhaseHasherMock!
    private var cocoaPodsScriptsHasher: ICocoaPodsScriptsHasherMock!
    private var configurationsHasher: IConfigurationsHasherMock!
    private var productHasher: IProductHasherMock!
    private var buildRulesHasher: IBuildRulesHasherMock!

    override func setUp() {
        super.setUp()
        foundationHasher = FoundationHasherMock()
        swiftVersionProvider = ISwiftVersionProviderMock()
        xcodeCLTVersionProvider = IXcodeCLTVersionProviderMock()
        buildPhaseHasher = IBuildPhaseHasherMock()
        cocoaPodsScriptsHasher = ICocoaPodsScriptsHasherMock()
        configurationsHasher = IConfigurationsHasherMock()
        productHasher = IProductHasherMock()
        buildRulesHasher = IBuildRulesHasherMock()
        sut = TargetsHasher(
            foundationHasher: foundationHasher,
            swiftVersionProvider: swiftVersionProvider,
            xcodeCLTVersionProvider: xcodeCLTVersionProvider,
            buildPhaseHasher: buildPhaseHasher,
            cocoaPodsScriptsHasher: cocoaPodsScriptsHasher,
            configurationsHasher: configurationsHasher,
            productHasher: productHasher,
            buildRulesHasher: buildRulesHasher
        )
    }

    override func tearDown() {
        super.tearDown()
        foundationHasher = nil
        swiftVersionProvider = nil
        xcodeCLTVersionProvider = nil
        buildPhaseHasher = nil
        cocoaPodsScriptsHasher = nil
        configurationsHasher = nil
        productHasher = nil
        buildRulesHasher = nil
        sut = nil // FIXME: Sometimes I catch EXC_BAD_ACCESS here
    }
}

extension TargetsHasherTests {
    func test_basic() async throws {
        let expectedAlamofireHashContext = """
        buildOptions:
          xcargs:
          - COMPILER_INDEX_STORE_ENABLE=NO
          - SWIFT_COMPILATION_MODE=wholemodule
        buildPhases:
        - Alamofire-framework_buildPhase_hash
        buildRules:
        - AlamofireBuildRule_cocoaPodsScripts_hash
        cocoaPodsScripts:
        - Alamofire-framework_cocoaPodsScripts_hash
        configurations:
        - Alamofire-framework_configuration_hash
        dependencies: {}
        name: Alamofire-framework
        product: null
        swift_version: \'5.9\'
        xcode_version: 14.5 (1234)\n
        """
        let alamofire = IInternalTargetMock()
        alamofire.underlyingName = "Alamofire-framework"
        alamofire.underlyingUuid = "3949679AB5CF3F2C77C15A0E67E8AF64"
        alamofire.buildRules = [.mock(name: "AlamofireBuildRule")]

        let expectedMoyaHashContext = """
        buildOptions:
          xcargs:
          - COMPILER_INDEX_STORE_ENABLE=NO
          - SWIFT_COMPILATION_MODE=wholemodule
        buildPhases:
        - Moya-framework_buildPhase_hash
        buildRules:
        - MoyaBuildRule_cocoaPodsScripts_hash
        cocoaPodsScripts:
        - Moya-framework_cocoaPodsScripts_hash
        configurations:
        - Moya-framework_configuration_hash
        dependencies:
          Alamofire-framework: Alamofire_hashed
        name: Moya-framework
        product:
          MoyaProduct: MoyaProduct_hash
        swift_version: \'5.9\'
        xcode_version: 14.5 (1234)\n
        """
        let moya = IInternalTargetMock()
        moya.underlyingName = "Moya-framework"
        moya.underlyingUuid = "3F66A14997A3B09C1C6CC3AFD763A745"
        moya.buildRules = [.mock(name: "MoyaBuildRule")]
        moya.product = Product(name: "Moya", moduleName: nil, type: .framework, parentFolderName: nil)
        moya.dependencies = [alamofire.uuid: alamofire]

        let expectedLocalPodResourcesHashContext = """
        buildOptions:
          xcargs:
          - COMPILER_INDEX_STORE_ENABLE=NO
          - SWIFT_COMPILATION_MODE=wholemodule
        buildPhases:
        - LocalPod-framework-LocalPodResources_buildPhase_hash
        buildRules:
        - LocalPodResourcesBuildRule_cocoaPodsScripts_hash
        cocoaPodsScripts:
        - LocalPod-framework-LocalPodResources_cocoaPodsScripts_hash
        configurations:
        - LocalPod-framework-LocalPodResources_configuration_hash
        dependencies: {}
        name: LocalPod-framework-LocalPodResources
        product: null
        swift_version: \'5.9\'
        xcode_version: 14.5 (1234)\n
        """
        let localPodResources = IInternalTargetMock()
        localPodResources.underlyingName = "LocalPod-framework-LocalPodResources"
        localPodResources.underlyingUuid = "4D46B2A355F0821E50320A2311A88AE9"
        localPodResources.buildRules = [.mock(name: "LocalPodResourcesBuildRule")]

        let expectedLocalPodHashContext = """
        buildOptions:
          xcargs:
          - COMPILER_INDEX_STORE_ENABLE=NO
          - SWIFT_COMPILATION_MODE=wholemodule
        buildPhases:
        - LocalPod-framework_buildPhase_hash
        buildRules:
        - LocalPodBuildRule_cocoaPodsScripts_hash
        cocoaPodsScripts:
        - LocalPod-framework_cocoaPodsScripts_hash
        configurations:
        - LocalPod-framework_configuration_hash
        dependencies:
          Alamofire-framework: Alamofire_hashed
          LocalPod-framework-LocalPodResources: LocalPodResources_hashed
          Moya-framework: Moya_hashed
        name: LocalPod-framework
        product: null
        swift_version: \'5.9\'
        xcode_version: 14.5 (1234)\n
        """
        let localPod = IInternalTargetMock()
        localPod.underlyingName = "LocalPod-framework"
        localPod.underlyingUuid = "1A5F2B8B18DD417D0FAA115D004EB177"
        localPod.buildRules = [.mock(name: "LocalPodBuildRule")]
        localPod.dependencies = [
            moya.uuid: moya,
            alamofire.uuid: alamofire,
            localPodResources.uuid: localPodResources
        ]

        let targets: TargetsMap = [
            alamofire.uuid: alamofire,
            localPod.uuid: localPod,
            moya.uuid: moya,
            localPodResources.uuid: localPodResources
        ]

        xcodeCLTVersionProvider.versionReturnValue = XcodeVersion(base: "14.5", build: "1234")

        await swiftVersionProvider.setSwiftVersionReturnValue("5.9")
        configurationsHasher.hashContextClosure = { ["\($0.name)_configuration_hash"] }
        cocoaPodsScriptsHasher.hashContextClosure = { ["\($0.name)_cocoaPodsScripts_hash"] }
        buildPhaseHasher.hashContextTargetClosure = { ["\($0.name)_buildPhase_hash"] }
        buildRulesHasher.hashContextClosure = {
            $0.map { "\($0.name ?? "Unknown")_cocoaPodsScripts_hash" }
        }
        productHasher.hashContextReturnValue = ["MoyaProduct": "MoyaProduct_hash"]
        foundationHasher.hashArrayOfStringsClosure = { $0.map { "\($0)_hashed" }.joined(separator: "|") }
        foundationHasher.hashStringClosure = {
            switch $0 {
            case expectedAlamofireHashContext: return "Alamofire_hashed"
            case expectedLocalPodHashContext: return "LocalPod_hashed"
            case expectedMoyaHashContext: return "Moya_hashed"
            case expectedLocalPodResourcesHashContext: return "LocalPodResources_hashed"
            default: fatalError()
            }
        }

        // Act
        try await sut.hash(targets, xcargs: [
            "COMPILER_INDEX_STORE_ENABLE=NO",
            "SWIFT_COMPILATION_MODE=wholemodule"
        ])

        // Assert
        XCTAssertEqual(alamofire.hashContext, expectedAlamofireHashContext)
        XCTAssertEqual(alamofire.hash, "Alamofire_hashed")

        XCTAssertEqual(localPod.hashContext, expectedLocalPodHashContext)
        XCTAssertEqual(localPod.hash, "LocalPod_hashed")

        XCTAssertEqual(localPodResources.hashContext, expectedLocalPodResourcesHashContext)
        XCTAssertEqual(localPodResources.hash, "LocalPodResources_hashed")

        XCTAssertEqual(moya.hashContext, expectedMoyaHashContext)
        XCTAssertEqual(moya.hash, "Moya_hashed")
    }

    func test_skip_hash() async throws {
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "3949679AB5CF3F2C77C15A0E67E8AF64"
        alamofire.hash = "test_hash"
        alamofire.hashContext = "test_hashContext"
        alamofire.targetHashContext = ["testKey": "testValue"]
        let targets: TargetsMap = [alamofire.uuid: alamofire]
        xcodeCLTVersionProvider.versionReturnValue = XcodeVersion(base: "14.5", build: "1234")

        // Act
        try await sut.hash(targets, xcargs: [], rehash: false)

        // Assert
        XCTAssertEqual(alamofire.hashContext, "test_hashContext")
        XCTAssertEqual(alamofire.hash, "test_hash")
        XCTAssertEqual(alamofire.targetHashContext as? [String: String], ["testKey": "testValue"])
    }

    func test_rehash() async throws {
        let alamofire = IInternalTargetMock()
        alamofire.underlyingName = "Alamofire-framework"
        alamofire.underlyingUuid = "3949679AB5CF3F2C77C15A0E67E8AF64"
        alamofire.hash = "test_hash"
        alamofire.hashContext = "test_hashContext"
        alamofire.targetHashContext = ["testKey": "testValue"]
        let targets: TargetsMap = [alamofire.uuid: alamofire]

        await swiftVersionProvider.setSwiftVersionReturnValue("5.9")
        configurationsHasher.hashContextReturnValue = []
        cocoaPodsScriptsHasher.hashContextReturnValue = []
        buildRulesHasher.hashContextReturnValue = []
        buildPhaseHasher.hashContextTargetReturnValue = []
        foundationHasher.hashArrayOfStringsReturnValue = "test_rehash_array"
        foundationHasher.hashStringReturnValue = "test_rehash"
        xcodeCLTVersionProvider.versionReturnValue = XcodeVersion(base: "14.5", build: "1234")

        // Act
        try await sut.hash(targets, xcargs: [], rehash: true)

        // Assert
        XCTAssertEqual(
            alamofire.hashContext,
            """
            buildOptions:
              xcargs: []
            buildPhases: []
            buildRules: []
            cocoaPodsScripts: []
            configurations: []
            dependencies: {}
            name: Alamofire-framework
            product: null
            swift_version: \'5.9\'
            xcode_version: 14.5 (1234)\n
            """
        )
        XCTAssertEqual(alamofire.hash, "test_rehash")
    }
}
