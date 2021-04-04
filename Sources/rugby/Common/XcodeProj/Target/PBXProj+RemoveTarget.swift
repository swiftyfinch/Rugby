//
//  PBXProj+RemoveTarget.swift
//  
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//

import XcodeProj

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
