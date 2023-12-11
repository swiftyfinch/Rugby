// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IBinariesCleanerMock: IBinariesCleaner {

    // MARK: - freeSpace

    var freeSpaceThrowableError: Error?
    var freeSpaceCallsCount = 0
    var freeSpaceCalled: Bool { freeSpaceCallsCount > 0 }
    var freeSpaceClosure: (() async throws -> Void)?

    func freeSpace() async throws {
        if let error = freeSpaceThrowableError {
            throw error
        }
        freeSpaceCallsCount += 1
        try await freeSpaceClosure?()
    }
}

// swiftlint:enable all
