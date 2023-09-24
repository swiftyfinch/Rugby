//
//  PBXFileElement+DisplayName.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 01.04.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import XcodeProj

extension PBXFileElement {
    var displayName: String? {
        name ?? path.map(URL.init(fileURLWithPath:))?.lastPathComponent
    }
}
