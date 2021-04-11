//
//  CacheSubstepFactory.swift
//  
//
//  Created by Vyacheslav Khorkov on 11.04.2021.
//

extension CacheSubstep {
    struct CacheSubstepFactory {
        let progress: RugbyProgressBar
        let command: Cache
        let metrics: Cache.Metrics

        var findRemotePods: FindRemotePods.Run {
            FindRemotePods(progress: progress, command: command, metrics: metrics).run
        }

        var findBuildPods: FindBuildPods.Run {
            FindBuildPods(progress: progress, command: command, metrics: metrics).run
        }

        var buildTargetsChain: BuildTargetsChain.Run {
            BuildTargetsChain(progress: progress).run
        }

        var addBuildTarget: AddBuildTarget.Run {
            AddBuildTarget(progress: progress).run
        }
    }
}
