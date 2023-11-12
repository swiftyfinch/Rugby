// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import RugbyFoundation

public final class IArchitectureProviderMock: IArchitectureProvider {

    public init() {}

    // MARK: - architecture

    public var architectureCallsCount = 0
    public var architectureCalled: Bool { architectureCallsCount > 0 }
    public var architectureReturnValue: Architecture!
    public var architectureClosure: (() -> Architecture)?

    public func architecture() -> Architecture {
        architectureCallsCount += 1
        if let architectureClosure = architectureClosure {
            return architectureClosure()
        } else {
            return architectureReturnValue
        }
    }
}

// swiftlint:enable all
