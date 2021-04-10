//
//  FindBuildPods.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstep {
    struct FindBuildPods: Step {
        struct Output {
            let target: String
            let project: XcodeProj
            let pods: Set<String>
            let buildPods: Set<String>
            let remoteChecksums: [String]
        }

        let progress: RugbyProgressBar
        let command: Cache
        let metrics: Cache.Metrics

        func run(_ input: FindRemotePods.Output) throws -> Output {
            let checksums = try Podfile(.podfileLock).getChecksums()
            let remoteChecksums = checksums.filter {
                guard let name = $0.components(separatedBy: ": ").first?
                        .trimmingCharacters(in: ["\""]) else { return false }
                return input.pods.contains(name)
            }
            metrics.checksums = remoteChecksums.count

            // Find checksums difference from cache file
            let buildPods: Set<String>
            let cacheFile = try CacheManager().load()
            if command.rebuild || command.sdk != cacheFile.sdk || command.arch != cacheFile.arch {
                buildPods = input.pods
            } else {
                let cachedChecksums = cacheFile.checksums
                let changes = Set(remoteChecksums).subtracting(cachedChecksums)
                let changedPods = changes.compactMap {
                    $0.components(separatedBy: ": ").first?.trimmingCharacters(in: ["\""])
                }
                buildPods = Set(changedPods)
            }
            return .init(target: input.target,
                         project: input.project,
                         pods: input.pods,
                         buildPods: buildPods,
                         remoteChecksums: remoteChecksums)
        }
    }
}
