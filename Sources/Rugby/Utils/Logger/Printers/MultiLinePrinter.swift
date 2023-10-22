import RugbyFoundation

// MARK: - Implementation

final class MultiLinePrinter {
    private let maxLevel: LogLevel
    private var shiftValue = 0

    init(maxLevel: LogLevel) {
        self.maxLevel = maxLevel
    }
}

// MARK: - Printer

extension MultiLinePrinter: Printer {
    func canPrint(level: LogLevel) -> Bool { level <= maxLevel }

    func shift() { shiftValue += 1 }
    func unshift() { shiftValue -= 1 }

    func print(
        _ text: String,
        icon: String?,
        duration: Double?,
        level: LogLevel,
        updateLine _: Bool
    ) {
        guard canPrint(level: level) else { return }
        let prefix = String(repeating: "  ", count: max(0, shiftValue - 1))
        let icon = icon.map { "\($0) " } ?? ""
        let duration = duration.map { "[\($0.format())] ".yellow } ?? ""
        Swift.print("\(prefix)\(icon)\(duration)\(text)")
    }
}
