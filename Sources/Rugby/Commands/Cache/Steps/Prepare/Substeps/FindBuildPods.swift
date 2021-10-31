//
//  FindBuildPods.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension CacheSubstepFactory {
    struct FindBuildPods: Step {
        let progress: Printer
        let command: Cache
        let metrics: Metrics
        let checksumsProvider = ChecksumsProvider()

        func run(_ selectedPods: Set<String>) throws -> (
            buildPods: Set<String>,
            swiftVersion: String?
        ) {
            let focusChecksums = try progress.spinner("Calculate checksums") {
                try checksumsProvider.getChecksums(forPods: selectedPods)
            }
            metrics.podsCount.after = focusChecksums.count

            // Find checksums difference from cache file
            let buildPods: Set<String>
            let cache = CacheManager().load(sdk: command.sdk, config: command.config)
            let swiftVersion = SwiftVersionProvider().swiftVersion()
            let xcargs = XCARGSProvider().xcargs
            let invalidCache = (
                command.arch != cache?.arch
                    || swiftVersion != cache?.swift
                    || command.config != cache?.config
                    || xcargs != cache?.xcargs
            )
            if let checksums = cache?.checksumsMap(), !command.ignoreChecksums, !invalidCache {
                let changes = focusChecksums.filter { checksums[$0.name]?.value != $0.value }
                let changedPods = changes.map(\.name)
                buildPods = Set(changedPods)
            } else {
                buildPods = selectedPods
            }
            return (buildPods, swiftVersion)
        }
    }
}
