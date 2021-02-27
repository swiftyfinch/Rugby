//
//  PBXFileElement+RemoveFilesRecursively.swift
//  
//
//  Created by Vyacheslav Khorkov on 21.02.2021.
//

import XcodeProj

extension PBXFileElement {
    func removeFilesRecursively(from project: PBXProj, pods: Set<String>) {
        if let name = name, parent?.name == "Pods", !pods.contains(name) { return }

        guard let group = self as? PBXGroup else {
            return project.delete(object: self)
        }

        for child in group.children {
            child.removeFilesRecursively(from: project, pods: pods)
        }

        if name == "Pods" { return }
        if group.parent?.name == "Pods" {
            (group.parent as? PBXGroup)?.children.removeAll { $0.name == name }
        }
        project.delete(object: group)
    }
}
