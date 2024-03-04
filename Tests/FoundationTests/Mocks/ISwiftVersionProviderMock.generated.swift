// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

public actor ISwiftVersionProviderMock: ISwiftVersionProvider {

    public init() {}

    // MARK: - swiftVersion

    public var swiftVersionThrowableError: Error?
    public var swiftVersionCallsCount = 0
    public var swiftVersionCalled: Bool { swiftVersionCallsCount > 0 }
    public var swiftVersionReturnValue: String!
    public func setSwiftVersionReturnValue(_ value: String) {
        swiftVersionReturnValue = value
    }
    public var swiftVersionClosure: (() throws -> String)?

    public func swiftVersion() throws -> String {
        swiftVersionCallsCount += 1
        if let error = swiftVersionThrowableError {
            throw error
        }
        if let swiftVersionClosure = swiftVersionClosure {
            return try swiftVersionClosure()
        } else {
            return swiftVersionReturnValue
        }
    }
}

// swiftlint:enable all
