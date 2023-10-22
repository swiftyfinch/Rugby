import RugbyFoundation

// MARK: - Implementation

final class MultiLinePrinter {
    private let maxLevel: LogLevel

    init(maxLevel: LogLevel) {
        self.maxLevel = maxLevel
    }
}

// MARK: - Printer

extension MultiLinePrinter: Printer {
    func canPrint(level: LogLevel) -> Bool { level <= maxLevel }

    func print(_ text: String, level: LogLevel, updateLine _: Bool) {
        guard canPrint(level: level) else { return }
        Swift.print(text)
    }
}
