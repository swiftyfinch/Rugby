//
//  BuildTargets.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstepFactory {
    struct BuildTargets: Step {
        let progress: Printer
        let command: Cache

        func run(_ input: (project: XcodeProj,
                           selectedPods: Set<String>,
                           buildPods: Set<String>)) throws -> (Set<PBXTarget>, Set<String>) {
            let selectedPodsChain = input.project.buildPodsChain(pods: input.selectedPods)
            guard selectedPodsChain.count >= input.selectedPods.count else { throw CacheError.cantFindPodsTargets }

            let additionalBuildTargets = Set(selectedPodsChain.map(\.name)).subtracting(input.selectedPods)
            if !additionalBuildTargets.isEmpty {
                progress.print(additionalBuildTargets, text: "Additional build targets")
            }

            let buildPodsChain = Set(input.project.buildPodsChain(pods: input.buildPods).map(\.name))
            let extendedBuildPodsChain: Set<String>
            if command.skipParents {
                extendedBuildPodsChain = buildPodsChain
                progress.print("Skip parents".yellow)
            } else {
                // Include parents of build pods. Maybe it's not necessary?
                extendedBuildPodsChain = input.project.findParentDependencies(buildPodsChain,
                                                                              allTargets: input.selectedPods)
            }

            return (selectedPodsChain, extendedBuildPodsChain)
        }
    }
}
