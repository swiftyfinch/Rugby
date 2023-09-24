//
//  Collection+ConcurrentMap.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 01.02.2023.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Collection {
    @discardableResult
    func concurrentMap<T>(
        maxInParallel: Int = Int.max,
        _ transform: @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: (offset: Int, value: T).self) { group in
            var offset = 0
            var iterator = makeIterator()
            while offset < maxInParallel, let element = iterator.next() {
                group.addTask { [offset] in try await (offset, transform(element)) }
                offset += 1
            }

            var result = [T?](repeating: nil, count: count)
            while let transformed = try await group.next() {
                result[transformed.offset] = transformed.value

                if let element = iterator.next() {
                    group.addTask { [offset] in try await (offset, transform(element)) }
                    offset += 1
                }
            }
            return result.compactMap()
        }
    }
}
