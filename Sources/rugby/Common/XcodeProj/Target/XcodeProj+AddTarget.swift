//
//  XcodeProj+AddTarget.swift
//  
//
//  Created by v.khorkov on 30.01.2021.
//

import XcodeProj

extension XcodeProj {
    func addTarget(name: String, dependencies: Set<String>) {
        let podsTargets = pbxproj.main.targets.filter { dependencies.contains($0.name) }
        let target = PBXAggregateTarget(name: name, productName: name)
        target.buildConfigurationList = podsTargets.first?.buildConfigurationList
        let dependencies = podsTargets.map { PBXTargetDependency(target: $0) }
        dependencies.forEach { pbxproj.add(object: $0) }
        target.dependencies = dependencies
        pbxproj.main.targets.append(target)
        pbxproj.add(object: target)
    }
}
