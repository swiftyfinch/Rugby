/// The protocol describing logger service.
public protocol ILogger: AnyObject {
    /// Configures the logger with specific printers.
    /// - Parameters:
    ///   - screenPrinter: A printer to handle the screen output.
    ///   - filePrinter: A printer to handle the file output.
    ///   - progressPrinter: A printer to handle the progress output.
    ///   - metricsLogger: A logger to handle the metrics output.
    func configure(
        screenPrinter: Printer?,
        filePrinter: Printer?,
        progressPrinter: IProgressPrinter?,
        metricsLogger: IMetricsLogger?
    ) async

    /// Logs block.
    /// - Parameters:
    ///   - header: A header of block.
    ///   - footer: A footer of block.
    ///   - metricKey: An optional metric key.
    ///   - level: A level of logging.
    ///   - output: An output type.
    ///   - block: An autoclosure to do.
    @discardableResult
    func log<Result>(
        _ header: String,
        footer: String?,
        metricKey: String?,
        level: LogLevel,
        output: LoggerOutput,
        auto block: @autoclosure () async throws -> Result
    ) async rethrows -> Result

    /// Logs block.
    /// - Parameters:
    ///   - header: A header of block.
    ///   - footer: A footer of block.
    ///   - metricKey: An optional metric key.
    ///   - level: A level of logging.
    ///   - output: An output type.
    ///   - block: A closure to do.
    @discardableResult
    func log<Result>(
        _ header: String,
        footer: String?,
        metricKey: String?,
        level: LogLevel,
        output: LoggerOutput,
        block: () async throws -> Result
    ) async rethrows -> Result

    /// Logs text.
    /// - Parameters:
    ///   - text: A text to log.
    ///   - level: A level of logging.
    ///   - output: An output type.
    func log(
        _ text: String,
        level: LogLevel,
        output: LoggerOutput
    ) async

    /// Logs plain text.
    /// - Parameters:
    ///   - text: A text to log.
    ///   - level: A level of logging.
    ///   - output: An output type.
    func logPlain(
        _ text: String,
        level: LogLevel,
        output: LoggerOutput
    ) async
}

/// Log level.
public enum LogLevel: Int, CaseIterable {
    case compact
    case info
}

/// Log output type.
public struct LoggerOutput: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The screen output.
    public static let screen = LoggerOutput(rawValue: 1 << 0)

    /// The file output.
    public static let file = LoggerOutput(rawValue: 1 << 1)

    /// The combination of all output.
    public static let all: LoggerOutput = [.screen, .file]
}
