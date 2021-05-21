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
            progress.print("Caclulate checksums ⏱".yellow, level: .vv)
            let checksumsProvider = try ChecksumsProvider(podfile: Podfile(.podfileLock))
            let focusChecksums = try checksumsProvider.getChecksums(forPods: selectedPods)
            metrics.podsCount.after = focusChecksums.count

            // Find checksums difference from cache file
            let buildPods: Set<String>
            let cache = CacheManager().load()?[command.sdk]
            let swiftVersion = SwiftVersionProvider().swiftVersion()
            let invalidCache = (command.arch != cache?.arch || swiftVersion != cache?.swift)
            if let checksums = cache?.checksumsMap(), !command.ignoreChecksums, !invalidCache {
                let changes = focusChecksums.filter { checksums[$0.name] == nil }
                let changedPods = changes.map(\.name)
                buildPods = Set(changedPods)
            } else {
                buildPods = selectedPods
            }
            return (buildPods, focusChecksums, swiftVersion)
        }
    }
}
