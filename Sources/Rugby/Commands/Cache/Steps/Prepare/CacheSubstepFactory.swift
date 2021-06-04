//
//  CacheSubstepFactory.swift
//  
//
//  Created by Vyacheslav Khorkov on 11.04.2021.
//

struct CacheSubstepFactory {
    let progress: Printer
    let command: Cache
    let metrics: Metrics

    var selectPods: SelectPods.Run {
        SelectPods(progress: progress, command: command, metrics: metrics).run
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
