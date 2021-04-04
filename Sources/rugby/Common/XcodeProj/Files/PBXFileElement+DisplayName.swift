//
//  PBXFileElement+DisplayName.swift
//  
//
//  Created by Vyacheslav Khorkov on 16.03.2021.
//

import XcodeProj

extension PBXFileElement {
    var displayName: String? {
        name ?? path?.filename()
    }
}
