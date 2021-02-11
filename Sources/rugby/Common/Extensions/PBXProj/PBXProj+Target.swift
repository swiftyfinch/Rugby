//
//  PBXProj+Target.swift
//  
//
//  Created by v.khorkov on 30.01.2021.
//

import XcodeProj

extension PBXProj {
    func addTarget(name: String, dependencies: [String]) {
        let podsTargets = main.targets.filter { dependencies.contains($0.name) }
        let target = PBXAggregateTarget(name: name, productName: name)
        target.buildConfigurationList = podsTargets[0].buildConfigurationList
        let dependencies = podsTargets.map { PBXTargetDependency(target: $0) }
        dependencies.forEach { add(object: $0) }
        target.dependencies = dependencies
        main.targets.append(target)
        add(object: target)
    }
}

extension PBXProj {
    func removeTarget(name: String) {
        guard let target = main.targets.first(where: { $0.name == name }) else { return }
        target.dependencies.forEach(delete)
        target.dependencies.forEach { $0.targetProxy.map(delete) }
        delete(object: target)
    }
}
