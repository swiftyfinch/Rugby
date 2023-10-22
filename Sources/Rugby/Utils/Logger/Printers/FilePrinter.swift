import Fish
import Foundation
import RugbyFoundation

// MARK: - Implementation

final class FilePrinter {
    private let file: IFile

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    init(file: IFile) {
        self.file = file
    }
}

// MARK: - Printer

extension FilePrinter: Printer {
    func canPrint(level _: LogLevel) -> Bool { true }

    func print(_ text: String, level _: LogLevel, updateLine _: Bool) {
        let time = timeFormatter.string(from: Date())
        let text = "[\(time)]: \(text)\n".raw
        try? file.append(text)
    }
}
