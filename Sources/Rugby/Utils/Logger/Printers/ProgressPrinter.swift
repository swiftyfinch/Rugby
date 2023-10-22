import Foundation
import RugbyFoundation

// MARK: - Implementation

final actor ProgressPrinter {
    private let frames = [
        "◔".yellow,
        "◔".yellow,
        "◑".yellow,
        "◑".yellow,
        "◕".yellow,
        "◕".yellow,
        "◉".yellow,
        "◉".yellow
    ]
    private let defaultFrame = "◔".yellow
    private let timeInterval: TimeInterval = 0.125

    // Dependencies
    private let printer: Printer

    // Variables
    private var timerTask: TimerTask?
    private var stopped = false

    init(printer: Printer) {
        self.printer = printer
    }

    func stop() {
        stopped = true
        cancel()
    }

    // MARK: - Private

    private func drawFrame(text: String, level: LogLevel) -> (() -> Void) {
        var frameIndex = -1
        let begin = ProcessInfo.processInfo.systemUptime
        return { [weak self] in
            guard let self else { return }

            frameIndex = (frameIndex + 1) % self.frames.count
            let frame = self.frames[frameIndex]
            let time = (ProcessInfo.processInfo.systemUptime - begin).rounded(.down)
            self.printer.print(text, icon: frame, duration: time, level: level, updateLine: true)
        }
    }
}

// MARK: - IProgressPrinter

extension ProgressPrinter: IProgressPrinter {
    func show<Result>(text: String,
                      level: LogLevel,
                      job: () async throws -> Result) async rethrows -> Result {
        guard !stopped else { return try await job() }

        cancel()
        let drawFrame = drawFrame(text: text, level: level)
        timerTask = TimerTask(interval: timeInterval, task: drawFrame)

        defer { cancel() }
        return try await job()
    }

    func cancel() {
        guard let task = timerTask else { return }
        task.cancel()
        timerTask = nil
    }
}
