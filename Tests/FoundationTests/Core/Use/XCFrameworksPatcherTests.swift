@testable import RugbyFoundation
import XCTest

final class XCFrameworksPatcherTests: XCTestCase {
    private var sut: IXCFrameworksPatcher!
    private var xcodeProject: IInternalXcodeProjectMock!
    private var xcodePhaseEditor: IXcodePhaseEditorMock!
    private var xcodeBuildConfigurationEditor: IXcodeBuildConfigurationEditorMock!

    override func setUp() {
        super.setUp()
        xcodeProject = IInternalXcodeProjectMock()
        xcodePhaseEditor = IXcodePhaseEditorMock()
        xcodeBuildConfigurationEditor = IXcodeBuildConfigurationEditorMock()
        sut = XCFrameworksPatcher(
            xcodeProject: xcodeProject,
            xcodePhaseEditor: xcodePhaseEditor,
            xcodeBuildConfigurationEditor: xcodeBuildConfigurationEditor
        )
    }

    override func tearDown() {
        xcodeProject = nil
        xcodePhaseEditor = nil
        xcodeBuildConfigurationEditor = nil
        sut = nil
        super.tearDown()
    }
}

extension XCFrameworksPatcherTests {
    func test_detachXCFrameworkBuildPhase() async throws {
        let target0 = IInternalTargetMock()
        target0.underlyingUuid = "target0_uuid"
        let target1 = IInternalTargetMock()
        target1.underlyingName = "target1_name"
        target1.underlyingUuid = "target1_uuid"
        let project1 = IProjectMock()
        target1.underlyingProject = project1
        let targets = [target0.uuid: target0, target1.uuid: target1]
        xcodePhaseEditor.filterXCFrameworksPhaseTargetsReturnValue = [target1.uuid: target1]
        let aggregatedTarget = IInternalTargetMock()
        aggregatedTarget.underlyingUuid = "aggregatedTarget_uuid"
        xcodeProject.createAggregatedTargetNameInDependenciesReturnValue = aggregatedTarget

        // Act
        try await sut.detachXCFrameworkBuildPhase(from: targets)

        // Assert
        XCTAssertEqual(xcodePhaseEditor.filterXCFrameworksPhaseTargetsCallsCount, 1)
        XCTAssertEqual(xcodePhaseEditor.filterXCFrameworksPhaseTargetsReceivedTargets?.count, 2)

        XCTAssertEqual(xcodeProject.createAggregatedTargetNameInDependenciesCallsCount, 1)
        XCTAssertEqual(xcodeProject.createAggregatedTargetNameInDependenciesReceivedArguments?.name,
                       "target1_name-XCFramework")
        XCTAssertIdentical(xcodeProject.createAggregatedTargetNameInDependenciesReceivedArguments?.project, project1)

        XCTAssertEqual(xcodePhaseEditor.copyXCFrameworksPhaseFromToCallsCount, 1)
        XCTAssertIdentical(xcodePhaseEditor.copyXCFrameworksPhaseFromToReceivedArguments?.target, target1)
        XCTAssertIdentical(xcodePhaseEditor.copyXCFrameworksPhaseFromToReceivedArguments?.destinationTarget,
                           aggregatedTarget)

        XCTAssertEqual(xcodeBuildConfigurationEditor.copyBuildConfigurationListFromToCallsCount, 1)
        XCTAssertIdentical(xcodeBuildConfigurationEditor.copyBuildConfigurationListFromToReceivedArguments?.target,
                           target1)
        XCTAssertIdentical(
            xcodeBuildConfigurationEditor.copyBuildConfigurationListFromToReceivedArguments?.destinationTarget,
            aggregatedTarget
        )

        XCTAssertEqual(xcodeProject.addDependenciesToCallsCount, 1)
        XCTAssertEqual(xcodeProject.addDependenciesToReceivedArguments?.dependencies.count, 1)
        XCTAssertIdentical(xcodeProject.addDependenciesToReceivedArguments?.dependencies.first?.value, aggregatedTarget)
        XCTAssertIdentical(xcodeProject.addDependenciesToReceivedArguments?.target, target1)

        XCTAssertEqual(xcodeProject.saveCallsCount, 1)
    }

    func test_detachXCFrameworkBuildPhase_empty() async throws {
        xcodePhaseEditor.filterXCFrameworksPhaseTargetsReturnValue = [:]

        // Act
        try await sut.detachXCFrameworkBuildPhase(from: [:])

        // Assert
        XCTAssertEqual(xcodeProject.saveCallsCount, 0)
    }
}
