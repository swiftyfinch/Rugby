//
//  SelectPods.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstepFactory {
    /// Find out which pods selected for caching
    struct SelectPods: Step {
        let progress: Printer
        let command: Cache
        let metrics: Metrics
        let podsProvider = PodsProvider.shared

        func run(_ project: XcodeProj) throws -> Set<String> {
            let pods: Set<String>
            if command.focus.isEmpty {
                pods = try podsProvider.remotePodsNames()
            } else {
                let allPods = try podsProvider.podsNames()
                pods = allPods.subtracting(command.focus)
            }
            progress.print(pods, text: "Pods", level: .vv)

            // Exclude by command argument
            var podsWithoutExcluded = pods
            if !command.exclude.isEmpty {
                progress.print(command.exclude, text: "Exclude pods", level: .vv)
                podsWithoutExcluded.subtract(command.exclude)
            }

            // Exclude aggregated targets, which contain scripts with the installation of some xcframeworks.
            let (filteredPods, excluded) = project.excludeXCFrameworksTargets(pods: podsWithoutExcluded)
            if !excluded.isEmpty {
                progress.print(excluded, text: "Exclude XCFrameworks", level: .vv)
            }

            metrics.podsCount.before = pods.count
            return filteredPods
        }
    }
}

private extension PodsProvider {
    func remotePodsNames() throws -> Set<String> {
        Set(try remotePods().map(\.name))
    }

    func podsNames() throws -> Set<String> {
        Set(try pods().map(\.name))
    }
}
