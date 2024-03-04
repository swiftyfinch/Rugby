// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IReachabilityCheckerMock: IReachabilityChecker {

    // MARK: - checkIfURLIsReachable

    var checkIfURLIsReachableThrowableError: Error?
    var checkIfURLIsReachableCallsCount = 0
    var checkIfURLIsReachableCalled: Bool { checkIfURLIsReachableCallsCount > 0 }
    var checkIfURLIsReachableReceivedUrl: URL?
    var checkIfURLIsReachableReceivedInvocations: [URL] = []
    var checkIfURLIsReachableReturnValue: Bool!
    var checkIfURLIsReachableClosure: ((URL) async throws -> Bool)?

    func checkIfURLIsReachable(_ url: URL) async throws -> Bool {
        checkIfURLIsReachableCallsCount += 1
        checkIfURLIsReachableReceivedUrl = url
        checkIfURLIsReachableReceivedInvocations.append(url)
        if let error = checkIfURLIsReachableThrowableError {
            throw error
        }
        if let checkIfURLIsReachableClosure = checkIfURLIsReachableClosure {
            return try await checkIfURLIsReachableClosure(url)
        } else {
            return checkIfURLIsReachableReturnValue
        }
    }
}

// swiftlint:enable all
