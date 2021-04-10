//
//  BuildTargetsChain.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstep {
    struct BuildTargetsChain: Step {
        struct Output {
            let target: String
            let project: XcodeProj
            let pods: Set<String>
            let buildPods: Set<String>
            let remoteChecksums: [String]
            let targets: Set<PBXTarget>
        }

        let progress: RugbyProgressBar

        func run(_ input: FindBuildPods.Output) throws -> Output {
            let remotePodsChain = input.project.buildRemotePodsChain(remotePods: Set(input.pods))
            guard remotePodsChain.count >= input.pods.count else { throw CacheError.cantFindRemotePodsTargets }

            let additionalBuildTargets = Set(remotePodsChain.map(\.name)).subtracting(input.pods)
            if !additionalBuildTargets.isEmpty {
                progress.output(additionalBuildTargets, text: "Additional build targets")
            }
            return .init(target: input.target,
                         project: input.project,
                         pods: input.pods,
                         buildPods: input.buildPods,
                         remoteChecksums: input.remoteChecksums,
                         targets: remotePodsChain)
        }
    }
}
