//
//  PBXFileElement+DisplayName.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 16.03.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXFileElement {
    var displayName: String? {
        name ?? path?.filename()
    }
}
