//
//  CacheSubstepFactory.swift
//  
//
//  Created by Vyacheslav Khorkov on 11.04.2021.
//

struct CacheSubstepFactory {
    let progress: Printer
    let command: Cache
    let metrics: Cache.Metrics

    var findRemotePods: FindRemotePods.Run {
        FindRemotePods(progress: progress, command: command, metrics: metrics).run
    }

    var findBuildPods: FindBuildPods.Run {
        FindBuildPods(progress: progress, command: command, metrics: metrics).run
    }

    var buildTargets: BuildTargets.Run {
        BuildTargets(progress: progress, command: command).run
    }

    var addBuildTarget: AddBuildTarget.Run {
        AddBuildTarget(progress: progress, command: command).run
    }
}
