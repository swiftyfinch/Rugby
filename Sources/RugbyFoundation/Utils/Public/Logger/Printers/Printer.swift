/// The protocol describing a printer which can be used in the logger.
public protocol Printer {
    /// Returns true if text can be printed.
    /// - Parameter level: A level for deciding if text should be printed.
    func canPrint(level: LogLevel) -> Bool

    /// Prints text.
    /// - Parameters:
    ///   - text: A text to print.
    ///   - level: A level for deciding if text should be printed.
    ///   - updateLine: An indicator to rewrite the previous line.
    func print(_ text: String, level: LogLevel, updateLine: Bool)
}
