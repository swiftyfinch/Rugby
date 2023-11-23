import XcodeProj

// MARK: - Interface

protocol IXcodePhaseEditor {
    /// Removes script phases after "Source" phase inclusive.
    func keepOnlyPreSourceScriptPhases(in targets: TargetsMap) async

    /// Deletes phase with "[CP] Copy XCFrameworks" name.
    func deleteCopyXCFrameworksPhase(in targets: TargetsMap) async
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
                if phase.name() == .copyXCFrameworks {
                    phase.files?.forEach(target.project.pbxProj.delete(object:))
                    target.project.pbxProj.delete(object: phase)
                    return true
                }
                return false
            }
        }
    }
}

// MARK: - Private extensions

private extension String {
    static let copyXCFrameworks = "[CP] Copy XCFrameworks"
}
