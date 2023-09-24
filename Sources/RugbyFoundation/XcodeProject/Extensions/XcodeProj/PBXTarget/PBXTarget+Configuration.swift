//
//  PBXTarget+Configuration.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 03.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXTarget {
    func constructConfigurations(
        _ projectBuildConfigurations: [String: XCBuildConfiguration]
    ) throws -> [String: Configuration]? {
        try buildConfigurationList?.buildConfigurations.reduce(into: [:]) { dictionary, config in
            guard let xcconfigPath = config.baseConfiguration?.fullPath,
                  let projectBuildSettings = projectBuildConfigurations[config.name]?.buildSettings else { return }

            let xcconfig = try XCConfig(path: .init(xcconfigPath))
            let buildSettings = projectBuildSettings
                .merging(xcconfig.buildSettings, uniquingKeysWith: combineKeys)
                .merging(config.buildSettings, uniquingKeysWith: combineKeys)

            dictionary?[config.name] = Configuration(name: config.name, buildSettings: buildSettings)
        }
    }

    private func combineKeys(_ lhs: Any, rhs: Any) -> Any {
        guard let lhs = lhs as? String, let rhs = rhs as? String else { return rhs }
        return rhs.replacingOccurrences(of: "$(inherited)", with: lhs)
    }
}
