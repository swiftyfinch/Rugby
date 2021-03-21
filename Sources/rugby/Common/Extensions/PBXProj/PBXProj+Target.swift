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
    @discardableResult
    func removeTarget(name: String) -> Bool {
        guard let target = main.targets.first(where: { $0.name == name }) else { return false }

        for phase in target.buildPhases {
            for file in phase.files ?? [] {
                delete(object: file)
            }
            delete(object: phase)
        }
        target.buildRules.forEach(delete)

        for configuration in target.buildConfigurationList?.buildConfigurations ?? [] {
            delete(object: configuration)
        }
        target.buildConfigurationList.map(delete)

        target.dependencies.forEach { $0.targetProxy.map(delete) }
        target.dependencies.forEach(delete)
        target.product.map(delete)

        delete(object: target)
        main.targets.removeAll(where: { $0.name == name })

        return true
    }
}
