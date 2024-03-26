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
    private let keepOnlyPreSourceScriptPhasesInReceivedInvocationsLock = NSRecursiveLock()
    var keepOnlyPreSourceScriptPhasesInClosure: ((TargetsMap) async -> Void)?

    func keepOnlyPreSourceScriptPhases(in targets: TargetsMap) async {
        keepOnlyPreSourceScriptPhasesInCallsCount += 1
        keepOnlyPreSourceScriptPhasesInReceivedTargets = targets
        keepOnlyPreSourceScriptPhasesInReceivedInvocationsLock.withLock {
            keepOnlyPreSourceScriptPhasesInReceivedInvocations.append(targets)
        }
        await keepOnlyPreSourceScriptPhasesInClosure?(targets)
    }

    // MARK: - deleteCopyXCFrameworksPhase

    var deleteCopyXCFrameworksPhaseInCallsCount = 0
    var deleteCopyXCFrameworksPhaseInCalled: Bool { deleteCopyXCFrameworksPhaseInCallsCount > 0 }
    var deleteCopyXCFrameworksPhaseInReceivedTargets: TargetsMap?
    var deleteCopyXCFrameworksPhaseInReceivedInvocations: [TargetsMap] = []
    private let deleteCopyXCFrameworksPhaseInReceivedInvocationsLock = NSRecursiveLock()
    var deleteCopyXCFrameworksPhaseInClosure: ((TargetsMap) async -> Void)?

    func deleteCopyXCFrameworksPhase(in targets: TargetsMap) async {
        deleteCopyXCFrameworksPhaseInCallsCount += 1
        deleteCopyXCFrameworksPhaseInReceivedTargets = targets
        deleteCopyXCFrameworksPhaseInReceivedInvocationsLock.withLock {
            deleteCopyXCFrameworksPhaseInReceivedInvocations.append(targets)
        }
        await deleteCopyXCFrameworksPhaseInClosure?(targets)
    }

    // MARK: - copyXCFrameworksPhase

    var copyXCFrameworksPhaseFromToCallsCount = 0
    var copyXCFrameworksPhaseFromToCalled: Bool { copyXCFrameworksPhaseFromToCallsCount > 0 }
    var copyXCFrameworksPhaseFromToReceivedArguments: (target: IInternalTarget, destinationTarget: IInternalTarget)?
    var copyXCFrameworksPhaseFromToReceivedInvocations: [(target: IInternalTarget, destinationTarget: IInternalTarget)] = []
    private let copyXCFrameworksPhaseFromToReceivedInvocationsLock = NSRecursiveLock()
    var copyXCFrameworksPhaseFromToClosure: ((IInternalTarget, IInternalTarget) -> Void)?

    func copyXCFrameworksPhase(from target: IInternalTarget, to destinationTarget: IInternalTarget) {
        copyXCFrameworksPhaseFromToCallsCount += 1
        copyXCFrameworksPhaseFromToReceivedArguments = (target: target, destinationTarget: destinationTarget)
        copyXCFrameworksPhaseFromToReceivedInvocationsLock.withLock {
            copyXCFrameworksPhaseFromToReceivedInvocations.append((target: target, destinationTarget: destinationTarget))
        }
        copyXCFrameworksPhaseFromToClosure?(target, destinationTarget)
    }

    // MARK: - filterXCFrameworksPhaseTargets

    var filterXCFrameworksPhaseTargetsCallsCount = 0
    var filterXCFrameworksPhaseTargetsCalled: Bool { filterXCFrameworksPhaseTargetsCallsCount > 0 }
    var filterXCFrameworksPhaseTargetsReceivedTargets: TargetsMap?
    var filterXCFrameworksPhaseTargetsReceivedInvocations: [TargetsMap] = []
    private let filterXCFrameworksPhaseTargetsReceivedInvocationsLock = NSRecursiveLock()
    var filterXCFrameworksPhaseTargetsReturnValue: TargetsMap!
    var filterXCFrameworksPhaseTargetsClosure: ((TargetsMap) -> TargetsMap)?

    func filterXCFrameworksPhaseTargets(_ targets: TargetsMap) -> TargetsMap {
        filterXCFrameworksPhaseTargetsCallsCount += 1
        filterXCFrameworksPhaseTargetsReceivedTargets = targets
        filterXCFrameworksPhaseTargetsReceivedInvocationsLock.withLock {
            filterXCFrameworksPhaseTargetsReceivedInvocations.append(targets)
        }
        if let filterXCFrameworksPhaseTargetsClosure = filterXCFrameworksPhaseTargetsClosure {
            return filterXCFrameworksPhaseTargetsClosure(targets)
        } else {
            return filterXCFrameworksPhaseTargetsReturnValue
        }
    }
}

// swiftlint:enable all
