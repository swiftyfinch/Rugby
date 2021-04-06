//
//  XcodeProj+Targets.swift
//  
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
//

import XcodeProj

extension XcodeProj {
    var targets: [PBXTarget] { pbxproj.main.targets }
}
