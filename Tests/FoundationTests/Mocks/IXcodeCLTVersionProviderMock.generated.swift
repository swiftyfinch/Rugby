// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IXcodeCLTVersionProviderMock: IXcodeCLTVersionProvider {

    // MARK: - version

    var versionThrowableError: Error?
    var versionCallsCount = 0
    var versionCalled: Bool { versionCallsCount > 0 }
    var versionReturnValue: (base: String, build: String?)!
    var versionClosure: (() throws -> (base: String, build: String?))?

    func version() throws -> (base: String, build: String?) {
        if let error = versionThrowableError {
            throw error
        }
        versionCallsCount += 1
        if let versionClosure = versionClosure {
            return try versionClosure()
        } else {
            return versionReturnValue
        }
    }
}

// swiftlint:enable all
