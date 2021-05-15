//
//  FindPods.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstepFactory {
    struct FindPods: Step {
        let progress: Printer
        let command: Cache
        let metrics: Metrics

        func run(_ project: XcodeProj) throws -> Set<String> {
            // Get pods from Podfile.lock
            let pods = Set(try Podfile(.podfileLock).getRemotePods())
            progress.print(pods, text: "Pods")

            // Exclude by command argument
            var podsWithoutExcluded = pods
            if !command.exclude.isEmpty {
                progress.print(command.exclude, text: "Exclude pods")
                podsWithoutExcluded.subtract(command.exclude)
            }

            // Exclude aggregated targets, which contain scripts with the installation of some xcframeworks.
            let (filteredPods, excluded) = project.excludeXCFrameworksTargets(pods: podsWithoutExcluded)
            if !excluded.isEmpty {
                progress.print(excluded, text: "Exclude XCFrameworks")
            }

            metrics.podsCount.before = pods.count
            return filteredPods
        }
    }
}
