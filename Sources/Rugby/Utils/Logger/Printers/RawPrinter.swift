import RugbyFoundation

// MARK: - Implementation

final class RawPrinter {
    private let standardOutput: IStandardOutput
    private let maxLevel: LogLevel

    init(standardOutput: IStandardOutput,
         maxLevel: LogLevel) {
        self.standardOutput = standardOutput
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
        standardOutput.print(text.raw)
    }
}
