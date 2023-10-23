import Foundation

// MARK: - Interface

protocol ITimerTask: AnyObject {
    func cancel()
}

// MARK: - Implementation

final class TimerTask: ITimerTask {
    private let interval: TimeInterval
    private let timer: Timer

    init(interval: TimeInterval, task: @escaping () -> Void) {
        self.interval = interval
        timer = Timer(timeInterval: interval, repeats: true) { _ in
            task()
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    func cancel() {
        timer.invalidate()
    }

    deinit {
        cancel()
    }
}
