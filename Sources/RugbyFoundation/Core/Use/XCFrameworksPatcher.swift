// MARK: - Interface

protocol IXCFrameworksPatcher: AnyObject {
    func detachXCFrameworkBuildPhase(from targets: TargetsMap) async throws
}

// MARK: - Implementation

final class XCFrameworksPatcher {
    private let xcodeProject: IInternalXcodeProject
    private let xcodePhaseEditor: IXcodePhaseEditor
    private let xcodeBuildConfigurationEditor: IXcodeBuildConfigurationEditor

    init(xcodeProject: IInternalXcodeProject,
         xcodePhaseEditor: IXcodePhaseEditor,
         xcodeBuildConfigurationEditor: IXcodeBuildConfigurationEditor) {
        self.xcodeProject = xcodeProject
        self.xcodePhaseEditor = xcodePhaseEditor
        self.xcodeBuildConfigurationEditor = xcodeBuildConfigurationEditor
    }
}

// MARK: - IXCFrameworksPatcher

extension XCFrameworksPatcher: IXCFrameworksPatcher {
    func detachXCFrameworkBuildPhase(from targets: TargetsMap) async throws {
        let xcframeworkScriptTargets = xcodePhaseEditor.filterXCFrameworksPhaseTargets(targets)
        for target in xcframeworkScriptTargets.values {
            let xcframeworkTarget = try await xcodeProject.createAggregatedTarget(
                name: "\(target.name)\(String.xcframeworkSuffix)",
                in: target.project
            )
            xcodePhaseEditor.copyXCFrameworksPhase(from: target, to: xcframeworkTarget)
            xcodeBuildConfigurationEditor.copyBuildConfigurationList(from: target, to: xcframeworkTarget)
            try xcodeProject.addDependencies([xcframeworkTarget.uuid: xcframeworkTarget], to: target)
        }
        if xcframeworkScriptTargets.isNotEmpty {
            try await xcodeProject.save()
        }
    }
}

private extension String {
    static let xcframeworkSuffix = "-XCFramework"
}
