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

    private func drawFrame(format: @escaping (String) -> String) -> (() -> Void) {
        var frameIndex = -1
        let begin = ProcessInfo.processInfo.systemUptime
        return { [weak self] in
            guard let self = self else { return }

            frameIndex = (frameIndex + 1) % self.frames.count
            let frame = self.frames[frameIndex]

            let time = ProcessInfo.processInfo.systemUptime - begin
            let formattedTime = "[\(time.format(withMilliseconds: false))]".yellow

            let output = format("\(frame) \(formattedTime)")
            self.printer.print(output, level: 0, updateLine: true)
        }
    }
}

// MARK: - IProgressPrinter

extension ProgressPrinter: IProgressPrinter {
    func show<Result>(format: @escaping (String) -> String,
                      job: () async throws -> Result) async rethrows -> Result {
        guard !stopped else { return try await job() }

        cancel()
        let drawFrame = drawFrame(format: format)
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
