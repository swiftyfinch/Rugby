//
//  BuildTargets.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
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
                progress.print(additionalBuildTargets, text: "Additional build targets", level: .vv)
            }

            let buildPodsChain = Set(input.project.buildPodsChain(pods: input.buildPods).map(\.name))
            let extendedBuildPodsChain: Set<String>
            if command.graph {
                progress.print("Resolving dependencies graph".yellow)
                extendedBuildPodsChain = input.project.findParentDependencies(buildPodsChain,
                                                                              allTargets: input.selectedPods)
            } else {
                extendedBuildPodsChain = buildPodsChain
            }

            return (selectedPodsChain, extendedBuildPodsChain)
        }
    }
}
