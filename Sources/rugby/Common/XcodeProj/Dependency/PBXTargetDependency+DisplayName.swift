//
//  PBXTargetDependency+DisplayName.swift
//  
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//

import XcodeProj

extension PBXTargetDependency {
    var displayName: String? {
        name ?? target?.name
    }
}
