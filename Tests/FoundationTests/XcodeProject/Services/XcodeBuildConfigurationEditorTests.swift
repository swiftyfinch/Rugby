@testable import RugbyFoundation
import XcodeProj
import XCTest

final class XcodeBuildConfigurationEditorTests: XCTestCase {
    private var sut: IXcodeBuildConfigurationEditor!

    override func setUp() {
        super.setUp()
        sut = XcodeBuildConfigurationEditor()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}

extension XcodeBuildConfigurationEditorTests {
    func test_copyBuildConfigurationList() {
        let target0 = IInternalTargetMock()
        target0.underlyingName = "ProcessOut"
        target0.underlyingUuid = "3386D53BC7DA45071FC1EA7213FCFC11"
        let pbxTarget0 = PBXTarget(name: "ProcessOut")
        let baseConfiguration0 = PBXFileReference(
            sourceTree: .group,
            path: "ProcessOut.debug.xcconfig",
            includeInIndex: true
        )
        let configuration0 = XCBuildConfiguration(
            name: "Debug",
            baseConfiguration: baseConfiguration0,
            buildSettings: ["SDKROOT": "iphoneos", "DEFINES_MODULE": "YES", "PRODUCT_MODULE_NAME": "ProcessOut"]
        )
        let baseConfiguration1 = PBXFileReference(
            sourceTree: .group,
            path: "ProcessOut.release.xcconfig",
            includeInIndex: true
        )
        let configuration1 = XCBuildConfiguration(
            name: "Release",
            baseConfiguration: baseConfiguration1,
            buildSettings: ["SDKROOT": "iphoneos", "DEFINES_MODULE": "YES", "PRODUCT_MODULE_NAME": "ProcessOut"]
        )
        let buildConfigurationList0 = XCConfigurationList(
            buildConfigurations: [configuration0, configuration1],
            defaultConfigurationName: "Debug",
            defaultConfigurationIsVisible: false
        )
        pbxTarget0.buildConfigurationList = buildConfigurationList0
        target0.underlyingPbxTarget = pbxTarget0
        let target1 = IInternalTargetMock()
        target1.underlyingName = "ProcessOut-XCFramework"
        target1.underlyingUuid = "target1_uuid"
        let project1 = IProjectMock()
        project1.pbxProj = PBXProj()
        target1.project = project1
        let pbxTarget1 = PBXTarget(name: "ProcessOut-XCFramework")
        target1.underlyingPbxTarget = pbxTarget1

        // Act
        sut.copyBuildConfigurationList(from: target0, to: target1)

        // Assert
        XCTAssertEqual(target1.project.pbxProj.buildConfigurations.count, 2)
        let expectedConfiguration0 = XCBuildConfiguration(
            name: "Debug",
            baseConfiguration: baseConfiguration0,
            buildSettings: ["SDKROOT": "iphoneos", "DEFINES_MODULE": "YES", "PRODUCT_MODULE_NAME": "ProcessOut"]
        )
        let expectedConfiguration1 = XCBuildConfiguration(
            name: "Release",
            baseConfiguration: baseConfiguration1,
            buildSettings: ["SDKROOT": "iphoneos", "DEFINES_MODULE": "YES", "PRODUCT_MODULE_NAME": "ProcessOut"]
        )
        XCTAssertEqual(target1.project.pbxProj.buildConfigurations.sorted(by: { $0.name < $1.name }),
                       [expectedConfiguration0, expectedConfiguration1])

        XCTAssertEqual(target1.project.pbxProj.configurationLists.count, 1)
        XCTAssertEqual(
            target1.project.pbxProj.configurationLists[0].buildConfigurations.sorted(by: { $0.name < $1.name }),
            [expectedConfiguration0, expectedConfiguration1]
        )
        XCTAssertEqual(target1.project.pbxProj.configurationLists[0].defaultConfigurationName, "Debug")
        XCTAssertEqual(target1.project.pbxProj.configurationLists[0].defaultConfigurationIsVisible, false)

        XCTAssertEqual(target1.pbxTarget.buildConfigurationList?.defaultConfigurationName, "Debug")
        XCTAssertEqual(target1.pbxTarget.buildConfigurationList?.defaultConfigurationIsVisible, false)
        XCTAssertEqual(target1.pbxTarget.buildConfigurationList?.buildConfigurations.count, 2)
        XCTAssertEqual(
            target1.pbxTarget.buildConfigurationList?.buildConfigurations.sorted(by: { $0.name < $1.name }),
            [expectedConfiguration0, expectedConfiguration1]
        )
    }
}
