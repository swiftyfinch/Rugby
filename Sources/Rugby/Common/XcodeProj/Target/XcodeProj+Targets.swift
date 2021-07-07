//
//  XcodeProj+Targets.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    var targets: [PBXTarget] { pbxproj.main.targets }
}
