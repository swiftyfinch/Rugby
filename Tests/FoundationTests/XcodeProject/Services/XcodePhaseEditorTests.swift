@testable import RugbyFoundation
import XcodeProj
import XCTest

final class XcodePhaseEditorTests: XCTestCase {
    private var sut: IXcodePhaseEditor!

    override func setUp() {
        super.setUp()
        sut = XcodePhaseEditor()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

extension XcodePhaseEditorTests {
    func test_keepOnlyPreSourceScriptPhases() async throws {
        let nativeTarget = IInternalTargetMock()
        nativeTarget.uuid = "test_nativeTarget_id"
        let project = IProjectMock()
        project.pbxProj = PBXProj()
        nativeTarget.project = project
        let nativeTargetBuildPhases: [PBXBuildPhase] = [
            PBXShellScriptBuildPhase(),
            PBXShellScriptBuildPhase(),
            PBXHeadersBuildPhase(),
            PBXSourcesBuildPhase(),
            PBXResourcesBuildPhase(),
            PBXShellScriptBuildPhase()
        ]
        nativeTarget.pbxTarget = PBXTarget(name: "test_nativeTarget_name",
                                           buildPhases: nativeTargetBuildPhases)

        let aggregateTarget = IInternalTargetMock()
        aggregateTarget.uuid = "test_aggregateTarget_id"
        aggregateTarget.project = project
        let aggregateTargetBuildPhases: [PBXBuildPhase] = [
            PBXShellScriptBuildPhase(),
            PBXShellScriptBuildPhase(name: "[CP] Copy XCFrameworks"),
            PBXHeadersBuildPhase(),
            PBXSourcesBuildPhase(),
            PBXResourcesBuildPhase(),
            PBXShellScriptBuildPhase()
        ]
        aggregateTarget.pbxTarget = PBXAggregateTarget(name: "test_aggregateTarget_name",
                                                       buildPhases: aggregateTargetBuildPhases)

        let targets = [nativeTarget.uuid: nativeTarget, aggregateTarget.uuid: aggregateTarget]

        // Act
        await sut.keepOnlyPreSourceScriptPhases(in: targets)

        // Assert
        let resultNativeTargetBuildPhases = try XCTUnwrap(targets[nativeTarget.uuid]?.pbxTarget.buildPhases)
        XCTAssertEqual(resultNativeTargetBuildPhases, Array(nativeTargetBuildPhases[0 ..< 2]))

        let resultAggregateTargetBuildPhases = try XCTUnwrap(targets[aggregateTarget.uuid]?.pbxTarget.buildPhases)
        XCTAssertEqual(resultAggregateTargetBuildPhases, Array(aggregateTargetBuildPhases[0 ..< 2]))
    }

    func test_deleteCopyXCFrameworksPhase() async throws {
        let nativeTarget = IInternalTargetMock()
        nativeTarget.uuid = "test_nativeTarget_id"
        let project = IProjectMock()
        project.pbxProj = PBXProj()
        nativeTarget.project = project
        let nativeTargetBuildPhases: [PBXBuildPhase] = [
            PBXShellScriptBuildPhase(),
            PBXShellScriptBuildPhase(),
            PBXHeadersBuildPhase(),
            PBXSourcesBuildPhase(),
            PBXResourcesBuildPhase(),
            PBXShellScriptBuildPhase()
        ]
        nativeTarget.pbxTarget = PBXTarget(name: "test_nativeTarget_name",
                                           buildPhases: nativeTargetBuildPhases)

        let aggregateTarget = IInternalTargetMock()
        aggregateTarget.uuid = "test_aggregateTarget_id"
        aggregateTarget.project = project
        let aggregateTargetBuildPhases: [PBXBuildPhase] = [
            PBXShellScriptBuildPhase(),
            PBXShellScriptBuildPhase(name: "[CP] Copy XCFrameworks"),
            PBXHeadersBuildPhase(),
            PBXSourcesBuildPhase(),
            PBXResourcesBuildPhase(),
            PBXShellScriptBuildPhase()
        ]
        aggregateTarget.pbxTarget = PBXAggregateTarget(name: "test_aggregateTarget_name",
                                                       buildPhases: aggregateTargetBuildPhases)

        let targets = [nativeTarget.uuid: nativeTarget, aggregateTarget.uuid: aggregateTarget]

        // Act
        await sut.deleteCopyXCFrameworksPhase(in: targets)

        // Assert
        let resultNativeTargetBuildPhases = try XCTUnwrap(targets[nativeTarget.uuid]?.pbxTarget.buildPhases)
        XCTAssertEqual(resultNativeTargetBuildPhases, nativeTargetBuildPhases)

        let resultAggregateTargetBuildPhases = try XCTUnwrap(targets[aggregateTarget.uuid]?.pbxTarget.buildPhases)
        var expectedAggregateTargetBuildPhases = aggregateTargetBuildPhases
        expectedAggregateTargetBuildPhases.remove(at: 1)
        XCTAssertEqual(resultAggregateTargetBuildPhases, expectedAggregateTargetBuildPhases)
    }
}
