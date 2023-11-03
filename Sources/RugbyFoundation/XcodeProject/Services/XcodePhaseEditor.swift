import XcodeProj

// MARK: - Interface

protocol IXcodePhaseEditor {
    /// Removes phases after "Source" inclusive.
    func keepOnlyPreSourcePhases(from targets: TargetsMap) async
}

// MARK: - Implementation

final class XcodePhaseEditor {
    private func removeBuildPhase(from target: IInternalTarget) {
        let buildPhases = target.pbxTarget.buildPhases
        guard let sourcesIndex = buildPhases.firstIndex(where: { $0.buildPhase == .sources }) else { return }

        buildPhases[sourcesIndex...].forEach {
            $0.files?.forEach(target.project.pbxProj.delete(object:))
            target.project.pbxProj.delete(object: $0)
        }
        target.pbxTarget.buildPhases.removeLast(buildPhases.count - sourcesIndex)
    }
}

extension XcodePhaseEditor: IXcodePhaseEditor {
    func keepOnlyPreSourcePhases(from targets: TargetsMap) async {
        await targets.values.concurrentForEach(removeBuildPhase(from:))
    }
}

// MARK: - Private extensions

private extension String {
    static let sources = "Sources"
}
