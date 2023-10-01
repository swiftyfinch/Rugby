import RugbyFoundation

// MARK: - Implementation

final class MultiLinePrinter {
    private let maxLevel: Int

    init(maxLevel: Int) {
        self.maxLevel = maxLevel
    }
}

// MARK: - Printer

extension MultiLinePrinter: Printer {
    func canPrint(level: Int) -> Bool { level <= maxLevel }

    func print(_ text: String, level: Int, updateLine _: Bool) {
        guard canPrint(level: level) else { return }
        Swift.print(text)
    }
}
