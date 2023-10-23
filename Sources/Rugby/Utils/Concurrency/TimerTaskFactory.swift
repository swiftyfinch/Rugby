import Foundation

// MARK: - Interface

protocol ITimerTaskFactory {
    func makeTask(interval: TimeInterval, task: @escaping () -> Void) -> ITimerTask
}

// MARK: - Implementation

final class TimerTaskFactory: ITimerTaskFactory {
    func makeTask(interval: TimeInterval, task: @escaping () -> Void) -> ITimerTask {
        TimerTask(interval: interval, task: task)
    }
}
