// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import Rugby

final class IClockMock: IClock {
    var systemUptime: TimeInterval {
        get { return underlyingSystemUptime }
        set(value) { underlyingSystemUptime = value }
    }
    var underlyingSystemUptime: TimeInterval!

    // MARK: - time

    var timeSinceSystemUptimeCallsCount = 0
    var timeSinceSystemUptimeCalled: Bool { timeSinceSystemUptimeCallsCount > 0 }
    var timeSinceSystemUptimeReceivedSinceSystemUptime: TimeInterval?
    var timeSinceSystemUptimeReceivedInvocations: [TimeInterval] = []
    var timeSinceSystemUptimeReturnValue: TimeInterval!
    var timeSinceSystemUptimeClosure: ((TimeInterval) -> TimeInterval)?

    func time(sinceSystemUptime: TimeInterval) -> TimeInterval {
        timeSinceSystemUptimeCallsCount += 1
        timeSinceSystemUptimeReceivedSinceSystemUptime = sinceSystemUptime
        timeSinceSystemUptimeReceivedInvocations.append(sinceSystemUptime)
        if let timeSinceSystemUptimeClosure = timeSinceSystemUptimeClosure {
            return timeSinceSystemUptimeClosure(sinceSystemUptime)
        } else {
            return timeSinceSystemUptimeReturnValue
        }
    }
}

// swiftlint:enable all
