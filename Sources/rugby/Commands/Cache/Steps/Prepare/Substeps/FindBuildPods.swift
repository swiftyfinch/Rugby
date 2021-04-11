//
//  FindBuildPods.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstep {
    struct FindBuildPods: Step {
        let progress: RugbyProgressBar
        let command: Cache
        let metrics: Cache.Metrics

        func run(_ pods: Set<String>) throws -> (buildPods: Set<String>, remoteChecksums: [String]) {
            let checksums = try Podfile(.podfileLock).getChecksums()
            let remoteChecksums = checksums.filter {
                guard let name = $0.components(separatedBy: ": ").first?
                        .trimmingCharacters(in: ["\""]) else { return false }
                return pods.contains(name)
            }
            metrics.checksums = remoteChecksums.count

            // Find checksums difference from cache file
            let buildPods: Set<String>
            let cacheFile = try CacheManager().load()
            if command.rebuild || command.sdk != cacheFile.sdk || command.arch != cacheFile.arch {
                buildPods = pods
            } else {
                let cachedChecksums = cacheFile.checksums
                let changes = Set(remoteChecksums).subtracting(cachedChecksums)
                let changedPods = changes.compactMap {
                    $0.components(separatedBy: ": ").first?.trimmingCharacters(in: ["\""])
                }
                buildPods = Set(changedPods)
            }
            return (buildPods, remoteChecksums)
        }
    }
}
