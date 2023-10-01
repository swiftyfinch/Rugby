extension Collection {
    @discardableResult
    func modifyIf(
        _ condition: Bool,
        _ transform: (inout Self) throws -> Void
    ) rethrows -> Self {
        guard condition else { return self }
        var copy = self
        try transform(&copy)
        return copy
    }
}
