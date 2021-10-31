//
//  XcodeProj+RemoveFilesRecursively.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 21.02.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    func removeFilesRecursively(fromFile file: PBXFileElement, rootGroup: String, pods: Set<String>) {
        guard let group = file as? PBXGroup else {
            // Remove single file
            return pbxproj.delete(object: file)
        }

        // Skip pod group in Pods if it hasn't included
        if let name = file.displayName, file.parent?.displayName == rootGroup, !pods.contains(name) { return }

        // Remove each file in group recursively
        group.children.forEach {
            removeFilesRecursively(fromFile: $0, rootGroup: rootGroup, pods: pods)
        }

        // Don't remove Pods group
        if file.displayName == rootGroup { return }

        // Remove group
        pbxproj.delete(object: group)

        // Remove group from parent
        if group.parent?.displayName == rootGroup {
            (group.parent as? PBXGroup)?.children.removeAll { $0.uuid == file.uuid }
        }
    }
}
