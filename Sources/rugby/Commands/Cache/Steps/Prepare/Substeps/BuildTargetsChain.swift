//
//  BuildTargetsChain.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstepFactory {
    struct BuildTargetsChain: Step {
        struct Input {
            let project: XcodeProj
            let pods: Set<String>
        }

        let progress: Printer

        func run(_ input: Input) throws -> Set<PBXTarget> {
            let remotePodsChain = input.project.buildRemotePodsChain(remotePods: Set(input.pods))
            guard remotePodsChain.count >= input.pods.count else { throw CacheError.cantFindRemotePodsTargets }

            let additionalBuildTargets = Set(remotePodsChain.map(\.name)).subtracting(input.pods)
            if !additionalBuildTargets.isEmpty {
                progress.print(additionalBuildTargets, text: "Additional build targets")
            }
            return remotePodsChain
        }
    }
}
