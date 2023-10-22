import RugbyFoundation

// MARK: - Implementation

final class RawPrinter {
    private let maxLevel: LogLevel

    init(maxLevel: LogLevel) {
        self.maxLevel = maxLevel
    }
}

// MARK: - Printer

extension RawPrinter: Printer {
    func canPrint(level: LogLevel) -> Bool { level <= maxLevel }

    func shift() {}
    func unshift() {}

    func print(
        _ text: String,
        icon _: String?,
        duration _: Double?,
        level: LogLevel,
        updateLine _: Bool
    ) {
        guard canPrint(level: level) else { return }
        Swift.print(text.raw)
    }
}
