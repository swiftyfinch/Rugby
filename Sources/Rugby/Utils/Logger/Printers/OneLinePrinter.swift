import RugbyFoundation

// MARK: - Implementation

final class OneLinePrinter {
    private let standardOutput: IStandardOutput
    private let maxLevel: LogLevel
    private let columns: Int
    private var shiftValue = 0

    init(standardOutput: IStandardOutput,
         maxLevel: LogLevel,
         columns: Int) {
        self.standardOutput = standardOutput
        self.maxLevel = maxLevel
        self.columns = columns
    }
}

// MARK: - Printer

extension OneLinePrinter: Printer {
    func canPrint(level: LogLevel) -> Bool { level <= maxLevel }

    func shift() { shiftValue += 1 }
    func unshift() { shiftValue -= 1 }

    func print(
        _ text: String,
        icon: String?,
        duration: Double?,
        level: LogLevel,
        updateLine: Bool
    ) {
        guard canPrint(level: level) else { return }
        let prefix = String(repeating: "  ", count: max(0, shiftValue - 1))
        let icon = icon.map { "\($0) " } ?? ""
        let duration = duration.map { "[\($0.format())] ".yellow } ?? ""
        let text = "\(prefix)\(icon)\(duration)\(text)"
        let choppedText = text.rainbowWidth(columns)
        standardOutput.print(updateLine ? "\u{1B}[1A\u{1B}[K\(choppedText)" : choppedText)
    }
}
