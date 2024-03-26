import XcodeProj

// MARK: - Interface

protocol IXcodePhaseEditor: AnyObject {
    /// Removes script phases after "Source" phase inclusive.
    func keepOnlyPreSourceScriptPhases(in targets: TargetsMap) async

    /// Deletes phase with "[CP] Copy XCFrameworks" name.
    func deleteCopyXCFrameworksPhase(in targets: TargetsMap) async

    /// Copies phase with "[CP] Copy XCFrameworks" name from one target to another.
    func copyXCFrameworksPhase(from target: IInternalTarget, to destinationTarget: IInternalTarget)

    /// Returns targets with "[CP] Copy XCFrameworks" phase.
    func filterXCFrameworksPhaseTargets(_ targets: TargetsMap) -> TargetsMap
}

// MARK: - Implementation

final class XcodePhaseEditor {}

extension XcodePhaseEditor: IXcodePhaseEditor {
    func keepOnlyPreSourceScriptPhases(in targets: TargetsMap) async {
        await targets.values.concurrentForEach { target in
            guard target.pbxTarget.buildPhases.contains(where: { $0.buildPhase == .sources }) else { return }

            var foundSources = false
            target.pbxTarget.buildPhases.removeAll { phase in
                if phase.buildPhase == .sources { foundSources = true }
                if phase.buildPhase != .runScript || foundSources {
                    phase.files?.forEach(target.project.pbxProj.delete(object:))
                    target.project.pbxProj.delete(object: phase)
                    return true
                }
                return false
            }
        }
    }

    func deleteCopyXCFrameworksPhase(in targets: TargetsMap) async {
        await targets.values.concurrentForEach { target in
            target.pbxTarget.buildPhases.removeAll { phase in
                if phase.isCopyXCFrameworks {
                    phase.files?.forEach(target.project.pbxProj.delete(object:))
                    target.project.pbxProj.delete(object: phase)
                    return true
                }
                return false
            }
        }
    }

    func copyXCFrameworksPhase(from target: IInternalTarget, to destinationTarget: IInternalTarget) {
        guard let xcframeworkBuildPhase = target.pbxTarget.buildPhases.first(where: \.isCopyXCFrameworks),
              let xcframeworkScriptBuildPhase = xcframeworkBuildPhase as? PBXShellScriptBuildPhase else { return }
        let copiedPhase = xcframeworkScriptBuildPhase.copy()
        destinationTarget.pbxTarget.buildPhases.append(copiedPhase)
        destinationTarget.project.pbxProj.add(object: copiedPhase)
    }

    func filterXCFrameworksPhaseTargets(_ targets: TargetsMap) -> TargetsMap {
        targets.filter { target in
            target.value.buildPhases.contains(where: \.isCopyXCFrameworks)
        }
    }
}

// MARK: - Private extensions

private extension String {
    static let copyXCFrameworks = "[CP] Copy XCFrameworks"
}

private extension BuildPhase {
    var isCopyXCFrameworks: Bool {
        name == .copyXCFrameworks
    }
}

private extension PBXBuildPhase {
    var isCopyXCFrameworks: Bool {
        name() == .copyXCFrameworks
    }
}

private extension PBXShellScriptBuildPhase {
    func copy() -> PBXShellScriptBuildPhase {
        PBXShellScriptBuildPhase(
            files: files ?? [],
            name: name,
            inputPaths: inputPaths,
            outputPaths: outputPaths,
            inputFileListPaths: inputFileListPaths,
            outputFileListPaths: outputFileListPaths,
            shellPath: shellPath ?? "/bin/sh",
            shellScript: shellScript,
            buildActionMask: buildActionMask,
            runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing,
            showEnvVarsInLog: showEnvVarsInLog,
            alwaysOutOfDate: alwaysOutOfDate,
            dependencyFile: dependencyFile
        )
    }
}
