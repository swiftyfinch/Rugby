extension Dictionary {
    @inlinable func partition(
        _ isLeftSide: (_ key: Key, _ value: Value) throws -> Bool
    ) rethrows -> ([Key: Value], [Key: Value]) {
        let matched = try filter(isLeftSide)
        return (matched, subtracting(matched))
    }
}
