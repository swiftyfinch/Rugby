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
        let command: Cache

        func run(_ input: Input) throws {
            let buildPodsChain: [String]
            if command.skipParents {
                buildPodsChain = Array(input.buildPods)
                progress.print("Skip parents".yellow)
            } else {
                // Include parents of build pods. Maybe it's not necessary?
                buildPodsChain = input.project.findParentDependencies(input.buildPods, allTargets: input.pods)
            }

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
