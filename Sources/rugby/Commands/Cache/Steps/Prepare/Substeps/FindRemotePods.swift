//
//  FindRemotePods.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstep {
    struct FindRemotePods: Step {
        let progress: RugbyProgressBar
        let command: Cache
        let metrics: Cache.Metrics

        func run(_ project: XcodeProj) throws -> Set<String> {
            // Get remote pods from Podfile.lock
            let remotePods = Set(try Podfile(.podfileLock).getRemotePods())
            progress.output(remotePods, text: "Remote pods")

            // Exclude by command argument
            var remotePodsWithoutExcluded = remotePods
            if !command.exclude.isEmpty {
                progress.output(command.exclude, text: "Exclude pods")
                remotePodsWithoutExcluded.subtract(command.exclude)
            }

            // Exclude aggregated targets, which contain scripts with the installation of some xcframeworks.
            let (filteredPods, excluded) = project.excludeXCFrameworksTargets(pods: remotePodsWithoutExcluded)
            if !excluded.isEmpty {
                progress.output(excluded, text: "Exclude XCFrameworks")
            }

            metrics.podsCount = remotePods.count
            return filteredPods
        }
    }
}
