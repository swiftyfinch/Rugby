// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IRugbyXcodeProjectMock: IRugbyXcodeProject {

    // MARK: - isAlreadyUsingRugby

    var isAlreadyUsingRugbyThrowableError: Error?
    var isAlreadyUsingRugbyCallsCount = 0
    var isAlreadyUsingRugbyCalled: Bool { isAlreadyUsingRugbyCallsCount > 0 }
    var isAlreadyUsingRugbyReturnValue: Bool!
    var isAlreadyUsingRugbyClosure: (() async throws -> Bool)?

    func isAlreadyUsingRugby() async throws -> Bool {
        if let error = isAlreadyUsingRugbyThrowableError {
            throw error
        }
        isAlreadyUsingRugbyCallsCount += 1
        if let isAlreadyUsingRugbyClosure = isAlreadyUsingRugbyClosure {
            return try await isAlreadyUsingRugbyClosure()
        } else {
            return isAlreadyUsingRugbyReturnValue
        }
    }

    // MARK: - markAsUsingRugby

    var markAsUsingRugbyThrowableError: Error?
    var markAsUsingRugbyCallsCount = 0
    var markAsUsingRugbyCalled: Bool { markAsUsingRugbyCallsCount > 0 }
    var markAsUsingRugbyClosure: (() async throws -> Void)?

    func markAsUsingRugby() async throws {
        if let error = markAsUsingRugbyThrowableError {
            throw error
        }
        markAsUsingRugbyCallsCount += 1
        try await markAsUsingRugbyClosure?()
    }
}

// swiftlint:enable all
