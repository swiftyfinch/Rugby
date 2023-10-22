/// The protocol describing a progress printer which can be used in the logger.
public protocol IProgressPrinter: Actor {
    /// Shows the progress.
    /// - Parameters:
    ///   - text: A text to print.
    ///   - level: A level for deciding if text should be printed.
    ///   - job: A job to do.
    func show<Result>(text: String,
                      level: LogLevel,
                      job: () async throws -> Result) async rethrows -> Result

    /// Cancels showing of the progress.
    func cancel()
}
