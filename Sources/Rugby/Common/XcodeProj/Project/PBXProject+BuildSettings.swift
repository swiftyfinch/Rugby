//
//  PBXProject+BuildSettings.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.02.2022.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXProject {
    func contains(buildSettingsKey: String) -> Bool {
        buildConfigurationList.buildConfigurations.contains {
            $0.buildSettings[buildSettingsKey] != nil
        }
    }

    func set(buildSettingsKey: String, value: Any) {
        buildConfigurationList.buildConfigurations.forEach {
            $0.buildSettings[buildSettingsKey] = value
        }
    }
}
