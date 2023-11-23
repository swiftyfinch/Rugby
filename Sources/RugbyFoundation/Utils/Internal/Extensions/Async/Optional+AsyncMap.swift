extension Optional {
    func map<U>(_ transform: (Wrapped) async throws -> U) async rethrows -> U? {
        switch self {
        case let .some(wrapped):
            return try await transform(wrapped)
        case .none:
            return nil
        }
    }
}
