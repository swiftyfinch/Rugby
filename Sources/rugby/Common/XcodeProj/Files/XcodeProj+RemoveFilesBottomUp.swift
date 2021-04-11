//
//  XcodeProj+RemoveFilesBottomUp.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.03.2021.
//

import XcodeProj

extension XcodeProj {
    func removeFilesBottomUp(files: [PBXBuildFile], excludeFiles: Set<String>) {
        removeFilesBottomUp(files: files.compactMap(\.file), excludeFiles: excludeFiles)
    }
}

extension XcodeProj {
    func removeFilesBottomUp(files: [PBXFileElement], excludeFiles: Set<String>) {
        files.forEach { file in
            if excludeFiles.contains(file.uuid) { return }

            if let currentGroup = file as? PBXGroup {
                removeFilesBottomUp(files: currentGroup.children, excludeFiles: excludeFiles)
            } else {
                let group = file.parent as? PBXGroup
                group?.children.removeAll { $0.uuid == file.uuid }
                pbxproj.delete(object: file)
                group.map { removeGroupIfEmpty($0, applyForParent: true) }
            }
        }
    }
}
