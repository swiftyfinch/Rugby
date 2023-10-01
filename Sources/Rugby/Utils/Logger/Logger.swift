import Foundation
import Rainbow
import RugbyFoundation

// MARK: - Implementation

final actor Logger {
    private let clock = "⚑".yellow
    private let done = "✓".green

    private var shift = 0
    private var lastEnter: String?

    private var screenPrinter: Printer?
    private var filePrinter: Printer?
    private var progressPrinter: IProgressPrinter?
    private var metricsLogger: IMetricsLogger?

    // MARK: - Log

    private func logToPrinters(
        _ text: String,
        level: Int,
        updateLine: Bool = false,
        output: LoggerOutput
    ) async {
        if output.contains(.screen), let screenPrinter, screenPrinter.canPrint(level: level) {
            await progressPrinter?.cancel()
            lastEnter = nil
        }
        if output.contains(.file) {
            filePrinter?.print(text, level: level, updateLine: updateLine)
        }
        if output.contains(.screen) {
            screenPrinter?.print(text, level: level, updateLine: updateLine)
        }
    }

    // MARK: - Prefix

    private func prefix() -> String { String(repeating: "  ", count: max(0, shift - 1)) }
    private func prefixOpen() -> String { "\(prefix())\(clock) " }
    private func prefixClose() -> String { "\(prefix())\(done) " }

    // MARK: - Step Wrapper

    private func enterBlock(
        _ title: String,
        level: LogLevel,
        output: LoggerOutput
    ) async {
        shift += 1
        await logToPrinters("\(prefixOpen())\(title)", level: level.rawValue, output: output)
        lastEnter = title
    }

    private func leaveBlock(
        _ title: String,
        _ time: Double? = nil,
        updateLine: Bool,
        level: LogLevel,
        output: LoggerOutput
    ) async {
        let formattedTime = time.map { "[\($0.format())] ".yellow } ?? ""
        let text = "\(prefixClose())\(formattedTime)\(title)"
        await logToPrinters(text, level: level.rawValue, updateLine: updateLine, output: output)
        shift -= 1
    }

    // MARK: - Measure

    private func measure<Result>(
        _ text: String,
        job: () async throws -> Result
    ) async rethrows -> (result: Result, time: Double) {
        let begin = ProcessInfo.processInfo.systemUptime
        let result: Result
        if let progressPrinter {
            let prefix = prefix()
            result = try await progressPrinter.show(
                format: { "\(prefix)\($0) \(text)" },
                job: job
            )
        } else {
            result = try await job()
        }
        return (result, ProcessInfo.processInfo.systemUptime - begin)
    }
}

// MARK: - ILogger

extension Logger: ILogger {
    func configure(
        screenPrinter: Printer?,
        filePrinter: Printer?,
        progressPrinter: IProgressPrinter?,
        metricsLogger: IMetricsLogger?
    ) async {
        self.screenPrinter = screenPrinter
        self.filePrinter = filePrinter
        self.progressPrinter = progressPrinter
        self.metricsLogger = metricsLogger
    }

    func log<Result>(
        _ header: String,
        footer: String? = nil,
        metricKey: String? = nil,
        level: LogLevel,
        output: LoggerOutput,
        auto block: @autoclosure () async throws -> Result
    ) async rethrows -> Result {
        try await log(
            header,
            footer: footer,
            metricKey: metricKey,
            level: level,
            output: output,
            block: block
        )
    }

    func log<Result>(
        _ header: String,
        footer: String?,
        metricKey: String?,
        level: LogLevel,
        output: LoggerOutput,
        block: () async throws -> Result
    ) async rethrows -> Result {
        await enterBlock(header, level: level, output: output)
        let (result, time) = try await measure(header, job: block)
        if time >= 0.1 { metricsLogger?.add(time, name: metricKey ?? header) }
        let updateLine = (lastEnter == header)
        await leaveBlock(
            updateLine ? header : footer ?? header,
            time >= 0.1 ? time : nil,
            updateLine: updateLine,
            level: level,
            output: output
        )
        return result
    }

    func log(
        _ text: String,
        level: LogLevel = .compact,
        output: LoggerOutput = .all
    ) async {
        shift += 1
        await logToPrinters(
            "\(prefixClose())\(text)",
            level: level.rawValue,
            output: output
        )
        shift -= 1
    }

    func logPlain(
        _ text: String,
        level: LogLevel = .compact,
        output: LoggerOutput = .all
    ) async {
        shift += 1
        for line in text.components(separatedBy: .newlines) {
            await logToPrinters(
                "\(prefix())\(line)",
                level: level.rawValue,
                output: output
            )
        }
        shift -= 1
    }
}
