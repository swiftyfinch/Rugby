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
    var hashXcargsRehashClosure: ((TargetsMap, [String], Bool) async throws -> Void)?

    func hash(_ targets: TargetsMap, xcargs: [String], rehash: Bool) async throws {
        if let error = hashXcargsRehashThrowableError {
            throw error
        }
        hashXcargsRehashCallsCount += 1
        hashXcargsRehashReceivedArguments = (targets: targets, xcargs: xcargs, rehash: rehash)
        hashXcargsRehashReceivedInvocations.append((targets: targets, xcargs: xcargs, rehash: rehash))
        try await hashXcargsRehashClosure?(targets, xcargs, rehash)
    }

    // MARK: - hash

    var hashXcargsThrowableError: Error?
    var hashXcargsCallsCount = 0
    var hashXcargsCalled: Bool { hashXcargsCallsCount > 0 }
    var hashXcargsReceivedArguments: (targets: TargetsMap, xcargs: [String])?
    var hashXcargsReceivedInvocations: [(targets: TargetsMap, xcargs: [String])] = []
    var hashXcargsClosure: ((TargetsMap, [String]) async throws -> Void)?

    func hash(_ targets: TargetsMap, xcargs: [String]) async throws {
        if let error = hashXcargsThrowableError {
            throw error
        }
        hashXcargsCallsCount += 1
        hashXcargsReceivedArguments = (targets: targets, xcargs: xcargs)
        hashXcargsReceivedInvocations.append((targets: targets, xcargs: xcargs))
        try await hashXcargsClosure?(targets, xcargs)
    }
}

// swiftlint:enable all
