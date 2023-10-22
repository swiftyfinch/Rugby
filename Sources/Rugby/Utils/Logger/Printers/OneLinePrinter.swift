import RugbyFoundation

// MARK: - Implementation

final class OneLinePrinter {
    private let maxLevel: LogLevel
    private let columns: Int

    init(maxLevel: LogLevel, columns: Int) {
        self.maxLevel = maxLevel
        self.columns = columns
    }
}

// MARK: - Printer

extension OneLinePrinter: Printer {
    func canPrint(level: LogLevel) -> Bool { level <= maxLevel }

    func print(_ text: String, level: LogLevel, updateLine: Bool) {
        guard canPrint(level: level) else { return }
        let choppedText = text.rainbowWidth(columns)
        Swift.print(updateLine ? "\u{1B}[1A\u{1B}[K\(choppedText)" : choppedText)
    }
}
