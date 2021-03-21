//
//  PBXGroup+RemoveIfEmpty.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.03.2021.
//

import XcodeProj

extension PBXGroup {
    func removeIfEmpty(project: PBXProj, applyForParent: Bool) {
        guard children.isEmpty else { return }
        (parent as? PBXGroup)?.children.removeAll { $0.uuid == uuid }
        let parentGroup = parent as? PBXGroup
        project.delete(object: self)
        guard applyForParent else { return }
        parentGroup?.removeIfEmpty(project: project, applyForParent: applyForParent)
    }
}
