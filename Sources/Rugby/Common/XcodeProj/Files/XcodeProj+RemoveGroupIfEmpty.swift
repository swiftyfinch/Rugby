//
//  XcodeProj+RemoveGroupIfEmpty.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 05.03.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    func removeGroupIfEmpty(_ group: PBXGroup, applyForParent: Bool) {
        guard group.children.isEmpty else { return }
        (group.parent as? PBXGroup)?.children.removeAll { $0.uuid == group.uuid }
        let parentGroup = group.parent as? PBXGroup
        pbxproj.delete(object: group)
        guard applyForParent else { return }
        parentGroup.map { removeGroupIfEmpty($0, applyForParent: applyForParent) }
    }
}
