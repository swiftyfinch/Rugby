// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IXcodeBuildConfigurationEditorMock: IXcodeBuildConfigurationEditor {

    // MARK: - copyBuildConfigurationList

    var copyBuildConfigurationListFromToCallsCount = 0
    var copyBuildConfigurationListFromToCalled: Bool { copyBuildConfigurationListFromToCallsCount > 0 }
    var copyBuildConfigurationListFromToReceivedArguments: (target: IInternalTarget, destinationTarget: IInternalTarget)?
    var copyBuildConfigurationListFromToReceivedInvocations: [(target: IInternalTarget, destinationTarget: IInternalTarget)] = []
    private let copyBuildConfigurationListFromToReceivedInvocationsLock = NSRecursiveLock()
    var copyBuildConfigurationListFromToClosure: ((IInternalTarget, IInternalTarget) -> Void)?

    func copyBuildConfigurationList(from target: IInternalTarget, to destinationTarget: IInternalTarget) {
        copyBuildConfigurationListFromToCallsCount += 1
        copyBuildConfigurationListFromToReceivedArguments = (target: target, destinationTarget: destinationTarget)
        copyBuildConfigurationListFromToReceivedInvocationsLock.withLock {
            copyBuildConfigurationListFromToReceivedInvocations.append((target: target, destinationTarget: destinationTarget))
        }
        copyBuildConfigurationListFromToClosure?(target, destinationTarget)
    }
}

// swiftlint:enable all
