//
//  AddBuildTarget.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstep {
    struct AddBuildTarget: Step {
        struct Output {
            let buildPods: Set<String>
            let remoteChecksums: [String]
            let targets: Set<PBXTarget>
        }

        let progress: RugbyProgressBar

        func run(_ input: CacheSubstep.BuildTargetsChain.Output) throws -> Output {
            // Include parents of build pods. Maybe it's not necessary?
            let buildPodsChain = input.project.findParentDependencies(Set(input.buildPods), allTargets: input.pods)
            if buildPodsChain.isEmpty {
                progress.update(info: "Skip".yellow)
            } else {
                progress.output(buildPodsChain, text: "Build pods")

                progress.update(info: "Add build target: ".yellow + input.target)
                input.project.pbxproj.addTarget(name: input.target, dependencies: buildPodsChain)

                progress.update(info: "Save project".yellow)
                try input.project.write(pathString: .podsProject, override: true)
            }
            return .init(buildPods: input.buildPods, remoteChecksums: input.remoteChecksums, targets: input.targets)
        }
    }
}
