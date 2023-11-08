// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IXcodePhaseEditorMock: IXcodePhaseEditor {

    // MARK: - keepOnlyPreSourceScriptPhases

    var keepOnlyPreSourceScriptPhasesInCallsCount = 0
    var keepOnlyPreSourceScriptPhasesInCalled: Bool { keepOnlyPreSourceScriptPhasesInCallsCount > 0 }
    var keepOnlyPreSourceScriptPhasesInReceivedTargets: TargetsMap?
    var keepOnlyPreSourceScriptPhasesInReceivedInvocations: [TargetsMap] = []
    var keepOnlyPreSourceScriptPhasesInClosure: ((TargetsMap) async -> Void)?

    func keepOnlyPreSourceScriptPhases(in targets: TargetsMap) async {
        keepOnlyPreSourceScriptPhasesInCallsCount += 1
        keepOnlyPreSourceScriptPhasesInReceivedTargets = targets
        keepOnlyPreSourceScriptPhasesInReceivedInvocations.append(targets)
        await keepOnlyPreSourceScriptPhasesInClosure?(targets)
    }

    // MARK: - deleteCopyXCFrameworksPhase

    var deleteCopyXCFrameworksPhaseInCallsCount = 0
    var deleteCopyXCFrameworksPhaseInCalled: Bool { deleteCopyXCFrameworksPhaseInCallsCount > 0 }
    var deleteCopyXCFrameworksPhaseInReceivedTargets: TargetsMap?
    var deleteCopyXCFrameworksPhaseInReceivedInvocations: [TargetsMap] = []
    var deleteCopyXCFrameworksPhaseInClosure: ((TargetsMap) async -> Void)?

    func deleteCopyXCFrameworksPhase(in targets: TargetsMap) async {
        deleteCopyXCFrameworksPhaseInCallsCount += 1
        deleteCopyXCFrameworksPhaseInReceivedTargets = targets
        deleteCopyXCFrameworksPhaseInReceivedInvocations.append(targets)
        await deleteCopyXCFrameworksPhaseInClosure?(targets)
    }
}

// swiftlint:enable all
