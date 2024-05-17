// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

public final class IXcodeCLTVersionProviderMock: IXcodeCLTVersionProvider {

    public init() {}

    // MARK: - version

    public var versionThrowableError: Error?
    public var versionCallsCount = 0
    public var versionCalled: Bool { versionCallsCount > 0 }
    public var versionReturnValue: XcodeVersion!
    public var versionClosure: (() throws -> XcodeVersion)?

    public func version() throws -> XcodeVersion {
        versionCallsCount += 1
        if let error = versionThrowableError {
            throw error
        }
        if let versionClosure = versionClosure {
            return try versionClosure()
        } else {
            return versionReturnValue
        }
    }
}

// swiftlint:enable all
