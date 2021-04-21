//
//  AddBuildTarget.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstepFactory {
    struct AddBuildTarget: Step {
        struct Input {
            let target: String
            let project: XcodeProj
            let pods: Set<String>
            let buildPods: Set<String>
        }

        let progress: Printer

        func run(_ input: Input) throws {
            // Include parents of build pods. Maybe it's not necessary?
            let buildPodsChain = input.project.findParentDependencies(Set(input.buildPods), allTargets: input.pods)
            if buildPodsChain.isEmpty {
                progress.print("Skip".yellow)
            } else {
                progress.print(buildPodsChain, text: "Build pods")

                progress.print("Add build target: ".yellow + input.target)
                input.project.addTarget(name: input.target, dependencies: buildPodsChain)

                progress.print("Save project ⏱".yellow)
                try input.project.write(pathString: .podsProject, override: true)
            }
        }
    }
}
