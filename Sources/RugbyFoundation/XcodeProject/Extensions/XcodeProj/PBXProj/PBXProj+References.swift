//
//  PBXProj+References.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 11.03.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXProj {
    func projectReferences() -> [PBXFileReference] {
        fileReferences.filter { $0.path?.hasSuffix(".xcodeproj") == true }
    }
}
