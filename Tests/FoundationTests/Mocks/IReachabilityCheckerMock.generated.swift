// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IReachabilityCheckerMock: IReachabilityChecker {

    // MARK: - checkIfURLIsReachable

    var checkIfURLIsReachableHeadersThrowableError: Error?
    var checkIfURLIsReachableHeadersCallsCount = 0
    var checkIfURLIsReachableHeadersCalled: Bool { checkIfURLIsReachableHeadersCallsCount > 0 }
    var checkIfURLIsReachableHeadersReceivedArguments: (url: URL, headers: [String: String])?
    var checkIfURLIsReachableHeadersReceivedInvocations: [(url: URL, headers: [String: String])] = []
    private let checkIfURLIsReachableHeadersReceivedInvocationsLock = NSRecursiveLock()
    var checkIfURLIsReachableHeadersReturnValue: Bool!
    var checkIfURLIsReachableHeadersClosure: ((URL, [String: String]) async throws -> Bool)?

    func checkIfURLIsReachable(_ url: URL, headers: [String: String]) async throws -> Bool {
        checkIfURLIsReachableHeadersCallsCount += 1
        checkIfURLIsReachableHeadersReceivedArguments = (url: url, headers: headers)
        checkIfURLIsReachableHeadersReceivedInvocationsLock.withLock {
            checkIfURLIsReachableHeadersReceivedInvocations.append((url: url, headers: headers))
        }
        if let error = checkIfURLIsReachableHeadersThrowableError {
            throw error
        }
        if let checkIfURLIsReachableHeadersClosure = checkIfURLIsReachableHeadersClosure {
            return try await checkIfURLIsReachableHeadersClosure(url, headers)
        } else {
            return checkIfURLIsReachableHeadersReturnValue
        }
    }
}

// swiftlint:enable all
