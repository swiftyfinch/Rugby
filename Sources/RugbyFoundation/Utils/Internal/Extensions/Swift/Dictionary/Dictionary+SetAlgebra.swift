extension Dictionary {
    @inlinable mutating func subtract(_ other: [Key: Value]) {
        other.keys.forEach { removeValue(forKey: $0) }
    }

    @inlinable func subtracting(_ other: [Key: Value]) -> [Key: Value] {
        var copy = self
        copy.subtract(other)
        return copy
    }

    @inlinable mutating func merge(_ other: [Key: Value]) {
        merge(other, uniquingKeysWith: { _, rhs in rhs })
    }

    @inlinable func merging(_ other: [Key: Value]) -> [Key: Value] {
        var copy = self
        copy.merge(other)
        return copy
    }

    @inlinable func keysIntersection(_ other: [Key: Value]) -> [Key: Value] {
        reduce(into: [:]) { dictionary, element in
            guard other[element.key] != nil else { return }
            dictionary[element.key] = element.value
        }
    }
}
