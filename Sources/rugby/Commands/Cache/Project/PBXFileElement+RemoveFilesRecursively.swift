//
//  PBXFileElement+RemoveFilesRecursively.swift
//  
//
//  Created by Vyacheslav Khorkov on 21.02.2021.
//

import XcodeProj

extension PBXFileElement {
    func removeFilesRecursively(from project: PBXProj, exclude: Set<String>) {
        if let name = name, parent?.name == "Pods", exclude.contains(name) { return }

        guard let group = self as? PBXGroup else {
            return project.delete(object: self)
        }

        for child in group.children {
            child.removeFilesRecursively(from: project, exclude: exclude)
        }

        if name == "Pods", !exclude.isEmpty { return }
        project.delete(object: group)
    }
}
