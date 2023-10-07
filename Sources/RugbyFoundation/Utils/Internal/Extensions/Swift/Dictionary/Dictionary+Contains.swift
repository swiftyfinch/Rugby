extension Dictionary {
    @inlinable func contains(_ key: Key) -> Bool {
        self[key] != nil
    }
}
