import Foundation
import Rainbow
import RugbyFoundation

// MARK: - Implementation

final actor Logger {
    private struct Shift: OptionSet {
        let rawValue: Int
        static let left = Shift(rawValue: 1 << 0)
        static let right = Shift(rawValue: 1 << 1)
    }

    private let beginIcon = "⚑".yellow
    private let doneIcon = "✓".green

    private var lastEnter: String?

    private var screenPrinter: Printer?
    private var filePrinter: Printer?
    private var progressPrinter: IProgressPrinter?
    private var metricsLogger: IMetricsLogger?

    // MARK: - Log

    private func logToPrinters(
        _ text: String,
        icon: String? = nil,
        duration: Double? = nil,
        level: LogLevel,
        updateLine: Bool = false,
        shifts: Shift = [],
        output: LoggerOutput
    ) async {
        if output.contains(.screen), let screenPrinter, screenPrinter.canPrint(level: level) {
            await progressPrinter?.cancel()
            if let lastEnter {
                await logToPrinter(
                    screenPrinter,
                    text: lastEnter,
                    icon: beginIcon,
                    level: level,
                    updateLine: true
                )
            }
            lastEnter = nil
        }
        if output.contains(.file), let filePrinter {
            await logToPrinter(
                filePrinter,
                text: text,
                icon: icon,
                duration: duration,
                level: level,
                updateLine: updateLine,
                shifts: shifts
            )
        }
        if output.contains(.screen), let screenPrinter {
            await logToPrinter(
                screenPrinter,
                text: text,
                icon: icon,
                duration: duration,
                level: level,
                updateLine: updateLine,
                shifts: shifts
            )
        }
    }

    private func logToPrinter(
        _ printer: Printer,
        text: String,
        icon: String? = nil,
        duration: Double? = nil,
        level: LogLevel,
        updateLine: Bool = false,
        shifts: Shift = []
    ) async {
        guard printer.canPrint(level: level) else { return }
        if shifts.contains(.right) {
            printer.shift()
        }
        printer.print(text, icon: icon, duration: duration, level: level, updateLine: updateLine)
        if shifts.contains(.left) {
            printer.unshift()
        }
    }

    // MARK: - Step Wrapper

    private func enterBlock(
        _ title: String,
        level: LogLevel,
        output: LoggerOutput
    ) async {
        await logToPrinters(
            title,
            icon: beginIcon,
            level: level,
            shifts: .right,
            output: output
        )
        if let screenPrinter, screenPrinter.canPrint(level: level) {
            lastEnter = title
        }
    }

    private func leaveBlock(
        _ title: String,
        _ duration: Double? = nil,
        updateLine: Bool,
        level: LogLevel,
        output: LoggerOutput
    ) async {
        await logToPrinters(
            title,
            icon: doneIcon,
            duration: duration,
            level: level,
            updateLine: updateLine,
            shifts: .left,
            output: output
        )
    }

    // MARK: - Measure

    private func measure<Result>(
        _ text: String,
        level: LogLevel,
        job: () async throws -> Result
    ) async rethrows -> (result: Result, time: Double) {
        let begin = ProcessInfo.processInfo.systemUptime
        let result: Result
        if let progressPrinter, let screenPrinter, screenPrinter.canPrint(level: level) {
            result = try await progressPrinter.show(text: text, level: level, job: job)
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
        let (result, duration) = try await measure(header, level: level, job: block)
        let notZeroDuration = (duration >= 0.1)
        if notZeroDuration { metricsLogger?.add(duration, name: metricKey ?? header) }
        let updateLine = (lastEnter == header)
        await leaveBlock(
            updateLine ? header : footer ?? header,
            notZeroDuration ? duration : nil,
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
        await logToPrinters(
            text,
            icon: doneIcon,
            level: level,
            shifts: [.right, .left],
            output: output
        )
    }

    func logPlain(
        _ text: String,
        level: LogLevel = .compact,
        output: LoggerOutput = .all
    ) async {
        for line in text.components(separatedBy: .newlines) {
            await logToPrinters(
                line,
                level: level,
                shifts: [.right, .left],
                output: output
            )
        }
    }

    func logList(
        _ list: [String],
        level: LogLevel,
        output: LoggerOutput
    ) async {
        for line in list {
            await logToPrinters(
                line,
                level: level,
                shifts: [.right, .left],
                output: output
            )
        }
    }
}
