//
//  Collection+ConcurrentFlatMap.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 15.03.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

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
