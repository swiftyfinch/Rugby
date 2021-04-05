//
//  CacheMetrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

extension Cache {
    final class Metrics {
        var podsCount: Int?
        var checksums: Int?

        func output() -> String {
            guard let podsCount = podsCount, let cachedPodsCount = checksums else { return "" }
            return "Cached \(cachedPodsCount)/\(podsCount) pods. ".green
        }
    }
}
