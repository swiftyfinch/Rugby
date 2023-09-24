//
//  PBXFileElement+FullPath.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 03.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXFileElement {
    var fullPath: String? {
        try? fullPath(sourceRoot: "Pods")
    }
}
