//
//  XcodeProj+RemoveTarget.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    @discardableResult
    func removeTarget(name: String) -> Bool {
        guard let target = pbxproj.main.targets.first(where: { $0.name == name }) else { return false }

        for phase in target.buildPhases {
            for file in phase.files ?? [] {
                pbxproj.delete(object: file)
            }
            pbxproj.delete(object: phase)
        }
        target.buildRules.forEach(pbxproj.delete)

        for configuration in target.buildConfigurationList?.buildConfigurations ?? [] {
            pbxproj.delete(object: configuration)
        }
        target.buildConfigurationList.map(pbxproj.delete)

        target.dependencies.forEach { $0.targetProxy.map(pbxproj.delete) }
        target.dependencies.forEach(pbxproj.delete)
        target.product.map(pbxproj.delete)

        pbxproj.delete(object: target)
        pbxproj.main.targets.removeAll(where: { $0.name == name })

        return true
    }

    @discardableResult
    func removeTargets(names: Set<String>) -> Bool {
        names.reduce(false) { removeTarget(name: $1) || $0 }
    }
}
