// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ISimCTLMock: ISimCTL {

    // MARK: - availableDevices

    var availableDevicesThrowableError: Error?
    var availableDevicesCallsCount = 0
    var availableDevicesCalled: Bool { availableDevicesCallsCount > 0 }
    var availableDevicesReturnValue: [Device]!
    var availableDevicesClosure: (() throws -> [Device])?

    func availableDevices() throws -> [Device] {
        availableDevicesCallsCount += 1
        if let error = availableDevicesThrowableError {
            throw error
        }
        if let availableDevicesClosure = availableDevicesClosure {
            return try availableDevicesClosure()
        } else {
            return availableDevicesReturnValue
        }
    }
}

// swiftlint:enable all
