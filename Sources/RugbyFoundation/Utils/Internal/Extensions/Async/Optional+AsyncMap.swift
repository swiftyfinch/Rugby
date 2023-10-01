extension Optional {
    func map<U>(_ transform: (Wrapped) async throws -> U) async rethrows -> U? {
        switch self {
        case .some(let wrapped):
            return try await transform(wrapped)
        case .none:
            return nil
        }
    }
}
