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
            let selectedPodsChain = input.project.buildPodsChain(pods: Set(input.selectedPods))
            guard selectedPodsChain.count >= input.selectedPods.count else { throw CacheError.cantFindPodsTargets }

            let additionalBuildTargets = Set(selectedPodsChain.map(\.name)).subtracting(input.selectedPods)
            if !additionalBuildTargets.isEmpty {
                progress.print(additionalBuildTargets, text: "Additional build targets")
            }

            let buildTargets: Set<String> = input.buildPods.reduce(into: []) { set, name in
                let targets = input.project.pbxproj.targets(named: name)
                let names = targets.map(\.name)
                set.formUnion(names)
            }

            let buildPodsChain: Set<String>
            if command.skipParents {
                buildPodsChain = buildTargets
                progress.print("Skip parents".yellow)
            } else {
                // Include parents of build pods. Maybe it's not necessary?
                buildPodsChain = input.project.findParentDependencies(buildTargets, allTargets: input.selectedPods)
            }

            return (selectedPodsChain, buildPodsChain)
        }
    }
}
