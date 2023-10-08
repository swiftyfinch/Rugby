extension Dictionary {
    @inlinable func flatMapValues<T>(_ transform: (Value) throws -> [Key: T]) rethrows -> [Key: T] {
        try reduce(into: [:]) { dictionary, element in
            try dictionary.merge(transform(element.value))
        }
    }
}

extension Dictionary {
    @inlinable func concurrentFlatMapValues<T>(
        _ transform: @escaping (Value) throws -> [Key: T]
    ) async rethrows -> [Key: T] {
        try await withThrowingTaskGroup(of: [Key: T].self) { group in
            values.forEach { value in
                group.addTask { try transform(value) }
            }
            return try await group.reduce(into: [:]) { result, dictionary in
                result.merge(dictionary)
            }
        }
    }
}
