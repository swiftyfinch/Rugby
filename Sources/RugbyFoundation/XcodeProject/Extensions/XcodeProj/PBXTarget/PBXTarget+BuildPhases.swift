//
//  PBXTarget+BuildPhases.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 30.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXTarget {
    func constructBuildPhases() -> [BuildPhase] {
        buildPhases.compactMap(BuildPhase.init)
    }
}
