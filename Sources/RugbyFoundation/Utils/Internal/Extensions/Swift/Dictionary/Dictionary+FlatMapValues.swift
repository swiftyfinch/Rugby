extension Dictionary {
    @inlinable func flatMapValues<T>(_ transform: (Value) throws -> [Key: T]) rethrows -> [Key: T] {
        try reduce(into: [:]) { dictionary, element in
            try dictionary.merge(transform(element.value))
        }
    }
}
