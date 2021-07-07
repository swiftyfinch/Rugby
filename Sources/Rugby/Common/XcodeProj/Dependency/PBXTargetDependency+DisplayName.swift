//
//  PBXTargetDependency+DisplayName.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXTargetDependency {
    var displayName: String? {
        name ?? target?.name
    }
}
