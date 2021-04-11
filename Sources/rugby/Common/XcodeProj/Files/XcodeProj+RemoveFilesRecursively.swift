//
//  XcodeProj+RemoveFilesRecursively.swift
//  
//
//  Created by Vyacheslav Khorkov on 21.02.2021.
//

import XcodeProj

extension XcodeProj {
    func removeFilesRecursively(fromFile file: PBXFileElement, pods: Set<String>) {
        guard let group = file as? PBXGroup else {
            // Remove single file
            return pbxproj.delete(object: file)
        }

        // Skip pod group in Pods if it hasn't included
        if let name = file.displayName, file.parent?.displayName == .podsGroup, !pods.contains(name) { return }

        // Remove each file in group recersively
        group.children.forEach {
            removeFilesRecursively(fromFile: $0, pods: pods)
        }

        // Don't remove Pods group
        if file.displayName == .podsGroup { return }

        // Remove group
        pbxproj.delete(object: group)

        // Remove group from parent
        if group.parent?.displayName == .podsGroup {
            (group.parent as? PBXGroup)?.children.removeAll { $0.uuid == file.uuid }
        }
    }
}
