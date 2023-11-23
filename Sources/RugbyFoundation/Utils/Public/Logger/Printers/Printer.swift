/// The protocol describing a printer which can be used in the logger.
public protocol Printer {
    /// Returns true if text can be printed.
    /// - Parameter level: A level for deciding if text should be printed.
    func canPrint(level: LogLevel) -> Bool

    /// Prints text.
    /// - Parameters:
    ///   - text: A text to print.
    ///   - icon: An icon to print with text. For example, a checkmark.
    ///   - duration: A duration of command to print with text. For example, [1.3s].
    ///   - level: A level for deciding if text should be printed.
    ///   - updateLine: An indicator to rewrite the previous line.
    func print(
        _ text: String,
        icon: String?,
        duration: Double?,
        level: LogLevel,
        updateLine: Bool
    )

    /// Shifts the beginning of line to the right.
    func shift()

    /// Shifts the beginning of line to the left.
    func unshift()
}
