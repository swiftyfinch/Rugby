//
//  PBXBuildFile+RemoveFilesBottomUp.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.03.2021.
//

import XcodeProj

extension Array where Element == PBXBuildFile {
    func removeFilesBottomUp(project: PBXProj, excludeFiles: Set<String>) throws {
        forEach { buildFile in
            guard let uuid = buildFile.file?.uuid else { return }
            if excludeFiles.contains(uuid) { return }
            let group = buildFile.file?.parent as? PBXGroup
            group?.children.removeAll { $0.uuid == uuid }
            buildFile.file.map(project.delete)
            group?.removeIfEmpty(project: project, applyForParent: true)
        }
    }
}
