//
//  Collection+ConcurrentCompactMap.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 15.03.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

extension Collection {
    @discardableResult
    func concurrentCompactMap<T>(
        maxInParallel: Int = Int.max,
        _ transform: @escaping (Element) async throws -> T?
    ) async rethrows -> [T] {
        try await concurrentMap(
            maxInParallel: maxInParallel,
            transform
        ).compactMap()
    }
}
