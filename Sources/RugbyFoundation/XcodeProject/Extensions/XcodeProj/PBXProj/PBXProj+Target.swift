//
//  PBXProj+Target.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 20.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXProj {
    func deleteTargetReferences(_ target: PBXTarget) throws {
        for phase in target.buildPhases {
            phase.files?.forEach(delete)
            delete(object: phase)
        }
        target.buildRules.forEach(delete)

        if target.buildConfigurationList != rootObject?.buildConfigurationList {
            target.buildConfigurationList?.buildConfigurations.forEach(delete)
            target.buildConfigurationList.map(delete)
        }

        target.dependencies.compactMap(\.targetProxy).forEach(delete)
        target.dependencies.forEach(delete)

        let productGroup = target.product?.parent as? PBXGroup
        productGroup?.children.removeAll { $0.uuid == target.product?.uuid }
        target.product.map(delete)

        delete(object: target)
        try rootProject()?.removeTargetAttributes(target: target)
    }
}
