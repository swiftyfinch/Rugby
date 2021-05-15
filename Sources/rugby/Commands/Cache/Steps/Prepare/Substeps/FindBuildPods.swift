//
//  FindBuildPods.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstepFactory {
    struct FindBuildPods: Step {
        let progress: Printer
        let command: Cache
        let metrics: Metrics

        func run(_ pods: Set<String>) throws -> (
            buildPods: Set<String>,
            focusChecksums: [String],
            swiftVersion: String?
        ) {
            let checksums = try Podfile(.podfileLock).getChecksums()
            let focusChecksums = checksums.filter {
                guard let name = $0.components(separatedBy: ": ").first?
                        .trimmingCharacters(in: ["\""]) else { return false }
                return pods.contains(name)
            }
            metrics.podsCount.after = focusChecksums.count

            // Find checksums difference from cache file
            let buildPods: Set<String>
            let cache = try CacheManager().load()
            let swiftVersion = SwiftVersionProvider().swiftVersion()
            let unsuitableCache = command.sdk != cache.sdk || command.arch != cache.arch || swiftVersion != cache.swift
            if command.ignoreCache || unsuitableCache {
                buildPods = pods
            } else {
                let cachedChecksums = cache.checksums
                let changes = Set(focusChecksums).subtracting(cachedChecksums)
                let changedPods = changes.compactMap {
                    $0.components(separatedBy: ": ").first?.trimmingCharacters(in: ["\""])
                }
                buildPods = Set(changedPods)
            }
            return (buildPods, focusChecksums, swiftVersion)
        }
    }
}
