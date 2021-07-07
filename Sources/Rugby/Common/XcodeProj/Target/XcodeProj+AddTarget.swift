//
//  XcodeProj+AddTarget.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 30.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    func addTarget(name: String, dependencies: Set<String>) {
        let podsTargets = pbxproj.main.targets.filter { dependencies.contains($0.name) }
        let target = PBXAggregateTarget(name: name, productName: name)
        target.buildConfigurationList = pbxproj.main.buildConfigurationList.copy()
        let dependencies = podsTargets.map { PBXTargetDependency(target: $0) }
        dependencies.forEach { pbxproj.add(object: $0) }
        target.dependencies = dependencies
        pbxproj.main.targets.append(target)
        pbxproj.add(object: target)
    }
}

private extension XCConfigurationList {
    func copy() -> XCConfigurationList {
        let copyBuildConfigurations = buildConfigurations.map {
            XCBuildConfiguration(name: $0.name,
                                 baseConfiguration: $0.baseConfiguration,
                                 buildSettings: $0.buildSettings)
        }
        return XCConfigurationList(buildConfigurations: copyBuildConfigurations,
                                   defaultConfigurationName: defaultConfigurationName,
                                   defaultConfigurationIsVisible: defaultConfigurationIsVisible)
    }
}
