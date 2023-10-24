import Foundation

// MARK: - Interface

protocol IClock: AnyObject {
    var systemUptime: TimeInterval { get }

    func time(sinceSystemUptime: TimeInterval) -> TimeInterval
}

// MARK: - Implementation

final class Clock: IClock {
    var systemUptime: TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }

    func time(sinceSystemUptime: TimeInterval) -> TimeInterval {
        systemUptime - sinceSystemUptime
    }
}
