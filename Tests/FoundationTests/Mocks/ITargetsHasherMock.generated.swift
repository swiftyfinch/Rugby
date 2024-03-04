// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ITargetsHasherMock: ITargetsHasher {

    // MARK: - hash

    var hashXcargsRehashThrowableError: Error?
    var hashXcargsRehashCallsCount = 0
    var hashXcargsRehashCalled: Bool { hashXcargsRehashCallsCount > 0 }
    var hashXcargsRehashReceivedArguments: (targets: TargetsMap, xcargs: [String], rehash: Bool)?
    var hashXcargsRehashReceivedInvocations: [(targets: TargetsMap, xcargs: [String], rehash: Bool)] = []
    private let hashXcargsRehashReceivedInvocationsLock = NSRecursiveLock()
    var hashXcargsRehashClosure: ((TargetsMap, [String], Bool) async throws -> Void)?

    func hash(_ targets: TargetsMap, xcargs: [String], rehash: Bool) async throws {
        hashXcargsRehashCallsCount += 1
        hashXcargsRehashReceivedArguments = (targets: targets, xcargs: xcargs, rehash: rehash)
        hashXcargsRehashReceivedInvocationsLock.withLock {
            hashXcargsRehashReceivedInvocations.append((targets: targets, xcargs: xcargs, rehash: rehash))
        }
        if let error = hashXcargsRehashThrowableError {
            throw error
        }
        try await hashXcargsRehashClosure?(targets, xcargs, rehash)
    }

    // MARK: - hash

    var hashXcargsThrowableError: Error?
    var hashXcargsCallsCount = 0
    var hashXcargsCalled: Bool { hashXcargsCallsCount > 0 }
    var hashXcargsReceivedArguments: (targets: TargetsMap, xcargs: [String])?
    var hashXcargsReceivedInvocations: [(targets: TargetsMap, xcargs: [String])] = []
    private let hashXcargsReceivedInvocationsLock = NSRecursiveLock()
    var hashXcargsClosure: ((TargetsMap, [String]) async throws -> Void)?

    func hash(_ targets: TargetsMap, xcargs: [String]) async throws {
        hashXcargsCallsCount += 1
        hashXcargsReceivedArguments = (targets: targets, xcargs: xcargs)
        hashXcargsReceivedInvocationsLock.withLock {
            hashXcargsReceivedInvocations.append((targets: targets, xcargs: xcargs))
        }
        if let error = hashXcargsThrowableError {
            throw error
        }
        try await hashXcargsClosure?(targets, xcargs)
    }
}

// swiftlint:enable all
