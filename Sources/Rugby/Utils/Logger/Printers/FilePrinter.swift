import Fish
import Foundation
import RugbyFoundation

// MARK: - Implementation

final class FilePrinter {
    private let file: IFile
    private var shiftValue = 0
    private var dateProvider: () -> Date

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    init(file: IFile, dateProvider: @escaping () -> Date = Date.init) {
        self.file = file
        self.dateProvider = dateProvider
    }
}

// MARK: - Printer

extension FilePrinter: Printer {
    func canPrint(level _: LogLevel) -> Bool { true }

    func shift() { shiftValue += 1 }
    func unshift() { shiftValue -= 1 }

    func print(
        _ text: String,
        icon: String?,
        duration: Double?,
        level _: LogLevel,
        updateLine _: Bool
    ) {
        let time = timeFormatter.string(from: dateProvider())
        let prefix = String(repeating: "  ", count: max(0, shiftValue - 1))
        let icon = icon.map { "\($0) " } ?? ""
        let duration = duration.map { "[\($0.format())] " } ?? ""
        let text = "[\(time)]: \(prefix)\(icon)\(duration)\(text)\n".raw
        try? file.append(text)
    }
}
