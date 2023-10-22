// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import RugbyFoundation

public final class ILoggerMock: ILogger {

    public init() {}

    // MARK: - configure

    public var configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerCallsCount = 0
    public var configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerCalled: Bool { configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerCallsCount > 0 }
    public var configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerReceivedArguments: (screenPrinter: Printer?, filePrinter: Printer?, progressPrinter: IProgressPrinter?, metricsLogger: IMetricsLogger?)?
    public var configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerReceivedInvocations: [(screenPrinter: Printer?, filePrinter: Printer?, progressPrinter: IProgressPrinter?, metricsLogger: IMetricsLogger?)] = []
    public var configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerClosure: ((Printer?, Printer?, IProgressPrinter?, IMetricsLogger?) async -> Void)?

    public func configure(screenPrinter: Printer?, filePrinter: Printer?, progressPrinter: IProgressPrinter?, metricsLogger: IMetricsLogger?) async {
        configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerCallsCount += 1
        configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerReceivedArguments = (screenPrinter: screenPrinter, filePrinter: filePrinter, progressPrinter: progressPrinter, metricsLogger: metricsLogger)
        configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerReceivedInvocations.append((screenPrinter: screenPrinter, filePrinter: filePrinter, progressPrinter: progressPrinter, metricsLogger: metricsLogger))
        await configureScreenPrinterFilePrinterProgressPrinterMetricsLoggerClosure?(screenPrinter, filePrinter, progressPrinter, metricsLogger)
    }

    // MARK: - log<Result>

    public var logFooterMetricKeyLevelOutputAutoCallsCount = 0
    public var logFooterMetricKeyLevelOutputAutoCalled: Bool { logFooterMetricKeyLevelOutputAutoCallsCount > 0 }
    public var logFooterMetricKeyLevelOutputAutoReturnValue: Any!
    public var logFooterMetricKeyLevelOutputAutoClosure: ((String, String?, String?, LogLevel, LoggerOutput, () async throws -> Any) async -> Any)?

    @discardableResult
    public func log<Result>(_ header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput, auto block: @autoclosure () async throws -> Result) async -> Result {
        logFooterMetricKeyLevelOutputAutoCallsCount += 1
        if let logFooterMetricKeyLevelOutputAutoClosure = logFooterMetricKeyLevelOutputAutoClosure {
            return await logFooterMetricKeyLevelOutputAutoClosure(header, footer, metricKey, level, output, block) as! Result
        } else {
            return logFooterMetricKeyLevelOutputAutoReturnValue as! Result
        }
    }

    // MARK: - log<Result>

    public var logFooterMetricKeyLevelOutputBlockCallsCount = 0
    public var logFooterMetricKeyLevelOutputBlockCalled: Bool { logFooterMetricKeyLevelOutputBlockCallsCount > 0 }
    public var logFooterMetricKeyLevelOutputBlockReturnValue: Any!
    public var logFooterMetricKeyLevelOutputBlockClosure: ((String, String?, String?, LogLevel, LoggerOutput, () async throws -> Any) async -> Any)?

    @discardableResult
    public func log<Result>(_ header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput, block: () async throws -> Result) async -> Result {
        logFooterMetricKeyLevelOutputBlockCallsCount += 1
        if let logFooterMetricKeyLevelOutputBlockClosure = logFooterMetricKeyLevelOutputBlockClosure {
            return await logFooterMetricKeyLevelOutputBlockClosure(header, footer, metricKey, level, output, block) as! Result
        } else {
            return logFooterMetricKeyLevelOutputBlockReturnValue as! Result
        }
    }

    // MARK: - log

    public var logLevelOutputCallsCount = 0
    public var logLevelOutputCalled: Bool { logLevelOutputCallsCount > 0 }
    public var logLevelOutputReceivedArguments: (text: String, level: LogLevel, output: LoggerOutput)?
    public var logLevelOutputReceivedInvocations: [(text: String, level: LogLevel, output: LoggerOutput)] = []
    public var logLevelOutputClosure: ((String, LogLevel, LoggerOutput) async -> Void)?

    public func log(_ text: String, level: LogLevel, output: LoggerOutput) async {
        logLevelOutputCallsCount += 1
        logLevelOutputReceivedArguments = (text: text, level: level, output: output)
        logLevelOutputReceivedInvocations.append((text: text, level: level, output: output))
        await logLevelOutputClosure?(text, level, output)
    }

    // MARK: - logPlain

    public var logPlainLevelOutputCallsCount = 0
    public var logPlainLevelOutputCalled: Bool { logPlainLevelOutputCallsCount > 0 }
    public var logPlainLevelOutputReceivedArguments: (text: String, level: LogLevel, output: LoggerOutput)?
    public var logPlainLevelOutputReceivedInvocations: [(text: String, level: LogLevel, output: LoggerOutput)] = []
    public var logPlainLevelOutputClosure: ((String, LogLevel, LoggerOutput) async -> Void)?

    public func logPlain(_ text: String, level: LogLevel, output: LoggerOutput) async {
        logPlainLevelOutputCallsCount += 1
        logPlainLevelOutputReceivedArguments = (text: text, level: level, output: output)
        logPlainLevelOutputReceivedInvocations.append((text: text, level: level, output: output))
        await logPlainLevelOutputClosure?(text, level, output)
    }

    // MARK: - logList

    public var logListLevelOutputCallsCount = 0
    public var logListLevelOutputCalled: Bool { logListLevelOutputCallsCount > 0 }
    public var logListLevelOutputReceivedArguments: (list: [String], level: LogLevel, output: LoggerOutput)?
    public var logListLevelOutputReceivedInvocations: [(list: [String], level: LogLevel, output: LoggerOutput)] = []
    public var logListLevelOutputClosure: (([String], LogLevel, LoggerOutput) async -> Void)?

    public func logList(_ list: [String], level: LogLevel, output: LoggerOutput) async {
        logListLevelOutputCallsCount += 1
        logListLevelOutputReceivedArguments = (list: list, level: level, output: output)
        logListLevelOutputReceivedInvocations.append((list: list, level: level, output: output))
        await logListLevelOutputClosure?(list, level, output)
    }
}

// swiftlint:enable all
