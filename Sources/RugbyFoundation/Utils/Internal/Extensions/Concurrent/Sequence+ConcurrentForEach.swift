extension Sequence {
    func concurrentForEach(
        maxInParallel: Int = Int.max,
        _ body: @escaping (Element) async throws -> Void
    ) async rethrows {
        try await withThrowingTaskGroup(of: Void.self) { group in
            var offset = 0
            var iterator = makeIterator()
            while offset < maxInParallel, let element = iterator.next() {
                group.addTask { try await body(element) }
                offset += 1
            }

            while try await group.next() != nil {
                if let element = iterator.next() {
                    group.addTask { try await body(element) }
                }
            }
        }
    }
}
