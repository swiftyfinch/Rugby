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

        func run(_ selectedPods: Set<String>) throws -> (
            buildPods: Set<String>,
            focusChecksums: [Checksum],
            swiftVersion: String?
        ) {
            let checksumsProvider = try ChecksumsProvider(podfile: Podfile(.podfileLock))
            let focusChecksums = try checksumsProvider.getChecksums(forPods: selectedPods)
            metrics.podsCount.after = focusChecksums.count

            // Find checksums difference from cache file
            let buildPods: Set<String>
            let cache = try CacheManager().load()
            let swiftVersion = SwiftVersionProvider().swiftVersion()
            let unsuitableCache = command.sdk != cache.sdk || command.arch != cache.arch || swiftVersion != cache.swift
            if command.ignoreCache || unsuitableCache {
                buildPods = selectedPods
            } else {
                let cachedChecksums = cache.checksums.compactMap(Checksum.init(string:))
                let changes = Set(focusChecksums).subtracting(cachedChecksums)
                let changedPods = changes.map(\.name)
                buildPods = Set(changedPods)
            }
            return (buildPods, focusChecksums, swiftVersion)
        }
    }
}
