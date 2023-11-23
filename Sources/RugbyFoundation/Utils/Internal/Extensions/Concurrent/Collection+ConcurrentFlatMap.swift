extension Collection {
    func concurrentFlatMap<T: Sequence>(
        maxInParallel: Int = Int.max,
        _ transform: @escaping (Element) async throws -> T
    ) async rethrows -> [T.Element] {
        try await concurrentMap(
            maxInParallel: maxInParallel,
            transform
        ).flatMap { $0 }
    }
}
