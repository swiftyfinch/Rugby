// MARK: - Interface

protocol IStandardOutput: AnyObject {
    func print(_ text: String)
}

// MARK: - Implementation

final class StandardOutput: IStandardOutput {
    func print(_ text: String) {
        Swift.print(text)
    }
}
