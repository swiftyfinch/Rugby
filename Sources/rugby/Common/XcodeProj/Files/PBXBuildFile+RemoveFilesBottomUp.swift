//
//  PBXBuildFile+RemoveFilesBottomUp.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.03.2021.
//

import XcodeProj

extension Array where Element == PBXBuildFile {
    func removeFilesBottomUp(project: PBXProj, excludeFiles: Set<String>) {
        compactMap(\.file).removeFilesBottomUp(project: project, excludeFiles: excludeFiles)
    }
}

private extension Array where Element == PBXFileElement {
    func removeFilesBottomUp(project: PBXProj, excludeFiles: Set<String>) {
        forEach { file in
            if excludeFiles.contains(file.uuid) { return }

            if let currentGroup = file as? PBXGroup {
                currentGroup.children.removeFilesBottomUp(project: project,
                                                          excludeFiles: excludeFiles)
            } else {
                let group = file.parent as? PBXGroup
                group?.children.removeAll { $0.uuid == file.uuid }
                project.delete(object: file)
                group?.removeIfEmpty(project: project, applyForParent: true)
            }
        }
    }
}
