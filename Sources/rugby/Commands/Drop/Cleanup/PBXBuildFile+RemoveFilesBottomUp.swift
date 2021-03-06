//
//  PBXBuildFile+RemoveFilesBottomUp.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.03.2021.
//

import XcodeProj

extension Array where Element == PBXBuildFile {
    func removeFilesBottomUp(project: PBXProj) throws {
        forEach { buildFile in
            let group = buildFile.file?.parent as? PBXGroup
            buildFile.file.map(project.delete)
            group?.removeIfEmpty(project: project, applyForParent: true)
        }
    }
}
