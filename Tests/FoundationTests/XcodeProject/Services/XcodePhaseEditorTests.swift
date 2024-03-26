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

    func test_filterXCFrameworksPhaseTargets() {
        let target0 = IInternalTargetMock()
        target0.underlyingName = "target0_name"
        target0.underlyingUuid = "target0_uuid"
        target0.buildPhases = [BuildPhase(name: "Some Script", type: .runScript)]
        let target1 = IInternalTargetMock()
        target1.underlyingName = "target1_name"
        target1.underlyingUuid = "target1_uuid"
        target1.buildPhases = [BuildPhase(name: "[CP] Copy XCFrameworks", type: .runScript)]
        let target2 = IInternalTargetMock()
        target2.underlyingName = "target2_name"
        target2.underlyingUuid = "target2_uuid"
        target2.buildPhases = [BuildPhase(name: "Sources", type: .sources)]

        // Act
        let filteredTargets = sut.filterXCFrameworksPhaseTargets([
            target0.uuid: target0,
            target1.uuid: target1,
            target2.uuid: target2
        ])

        // Assert
        XCTAssertEqual(filteredTargets.count, 1)
        XCTAssertEqual(filteredTargets.first?.value.name, target1.name)
    }

    func test_copyXCFrameworksPhase() {
        let target0 = IInternalTargetMock()
        target0.underlyingName = "target0_name"
        target0.underlyingUuid = "target0_uuid"
        target0.underlyingPbxTarget = PBXTarget(name: "target0_name")
        let project = IProjectMock()
        project.pbxProj = PBXProj()
        target0.underlyingProject = project
        let target1 = IInternalTargetMock()
        target1.underlyingName = "target1_name"
        target1.underlyingUuid = "target1_uuid"
        target1.underlyingPbxTarget = PBXTarget(name: "target1_name")
        let xcframeworkBuildPhase = PBXShellScriptBuildPhase(
            files: [],
            name: "[CP] Copy XCFrameworks",
            inputPaths: ["inputPaths_test"],
            outputPaths: ["outputPaths_test"],
            inputFileListPaths: ["inputFileListPaths_test"],
            outputFileListPaths: ["outputFileListPaths_test"],
            shellPath: "shellPath_test",
            shellScript: "shellScript_test",
            buildActionMask: 99,
            runOnlyForDeploymentPostprocessing: false,
            showEnvVarsInLog: false,
            alwaysOutOfDate: false,
            dependencyFile: "dependencyFile_test"
        )
        target1.pbxTarget.buildPhases = [xcframeworkBuildPhase]

        // Act
        sut.copyXCFrameworksPhase(from: target1, to: target0)

        // Assert
        XCTAssertEqual(target0.pbxTarget.buildPhases.first, xcframeworkBuildPhase)
    }
}
