//
//  XcodeProj+ExcludeXCFrameworksTargets.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 08.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    func excludeXCFrameworksTargets(pods: Set<String>) -> (filteredPods: Set<String>, excluded: Set<String>) {
        let aggregateTargets = pbxproj.aggregateTargets.reduce(into: Set<String>()) { set, target in
            let phaseNames = target.buildPhases.compactMap { $0.name() }
            if phaseNames.contains(where: { $0.contains("XCFrameworks") }) {
                set.insert(target.name)
            }
        }
        return (filteredPods: pods.subtracting(aggregateTargets), aggregateTargets)
    }
}
