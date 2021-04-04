//
//  PBXFileElement+RemoveFilesRecursively.swift
//  
//
//  Created by Vyacheslav Khorkov on 21.02.2021.
//

import XcodeProj

extension PBXFileElement {
    func removeFilesRecursively(from project: PBXProj, pods: Set<String>) {
        guard let group = self as? PBXGroup else {
            // Remove single file
            return project.delete(object: self)
        }

        // Skip pod group in Pods if it hasn't included
        if let name = displayName, parent?.displayName == .podsGroup, !pods.contains(name) { return }

        // Remove each file in group recersively
        group.children.forEach { $0.removeFilesRecursively(from: project, pods: pods) }

        // Don't remove Pods group
        if displayName == .podsGroup { return }

        // Remove group
        project.delete(object: group)

        // Remove group from parent
        if group.parent?.displayName == .podsGroup {
            (group.parent as? PBXGroup)?.children.removeAll { $0.uuid == uuid }
        }
    }
}
