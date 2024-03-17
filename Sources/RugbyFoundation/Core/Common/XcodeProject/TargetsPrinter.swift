// MARK: - Interface

protocol ITargetsPrinter: AnyObject {
    func print(_ targets: TargetsMap) async
}

// MARK: - Implementation

final class TargetsPrinter: Loggable {
    let logger: ILogger

    init(logger: ILogger) {
        self.logger = logger
    }
}

// MARK: - ITargetsPrinter

extension TargetsPrinter: ITargetsPrinter {
    func print(_ targets: TargetsMap) async {
        await logList(targets.map { "  \("*".yellow) \($0.value.name)" }.caseInsensitiveSorted())
    }
}
