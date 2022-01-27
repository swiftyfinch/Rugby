//
//  FindBuildPods.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import XcodeProj

extension CacheSubstepFactory {
    struct FindBuildPods: Step {
        let progress: Printer
        let command: Cache
        let metrics: Metrics

        private let checksumsProvider = ChecksumsProvider()
        private let xcargsProvider = XCARGSProvider()

        func run(_ selectedPods: Set<String>) throws -> (
            buildInfo: BuildInfo,
            swiftVersion: String
        ) {
            guard let swiftVersion = SwiftVersionProvider().swiftVersion() else {
                throw CacheError.cantGetSwiftVersion
            }

            let focusChecksums = try progress.spinner("Calculate checksums") {
                try checksumsProvider.getChecksums(forPods: selectedPods)
            }
            metrics.podsCount.after = focusChecksums.count

            // Find checksums difference from cache file
            var buildPods: Set<String> = []
            let xcargs = xcargsProvider.xcargs(bitcode: command.bitcode)
            var buildSDKs: [SDK] = []
            var buildARCHs: [String] = []
            for (sdk, arch) in zip(command.sdk, command.arch) {
                let cache = CacheManager().load(sdk: sdk.xcodebuild, config: command.config, arch: arch)
                let invalidCache = (
                    arch != cache?.arch
                        || swiftVersion != cache?.swift
                        || command.config != cache?.config
                        || xcargs != cache?.xcargs
                )
                if let checksums = cache?.checksumsMap(), !command.ignoreChecksums, !invalidCache {
                    let changes = focusChecksums.filter { checksums[$0.name]?.value != $0.value }
                    let changedPods = changes.map(\.name)
                    buildPods.formUnion(changedPods)
                } else {
                    buildPods.formUnion(selectedPods)
                }
                if !buildPods.isEmpty {
                    buildSDKs.append(sdk)
                    buildARCHs.append(arch)
                }
            }
            return (BuildInfo(pods: buildPods, sdk: buildSDKs, arch: buildARCHs), swiftVersion)
        }
    }
}
