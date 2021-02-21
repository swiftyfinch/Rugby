//
//  PBXFileElement+RemoveFilesRecursively.swift
//  
//
//  Created by Vyacheslav Khorkov on 21.02.2021.
//

import XcodeProj

extension PBXFileElement {
    func removeFilesRecursively(from project: PBXProj) {
        guard let group = self as? PBXGroup else {
            return project.delete(object: self)
        }
        for child in group.children {
            child.removeFilesRecursively(from: project)
        }
        project.delete(object: group)
    }
}
