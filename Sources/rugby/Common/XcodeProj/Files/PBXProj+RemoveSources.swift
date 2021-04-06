//
//  PBXProj+RemoveSources.swift
//  
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
//

import XcodeProj

extension XcodeProj {
    func removeSources(fromTargets names: Set<String>, excludeFiles: Set<String>) throws {
        let targets = pbxproj.main.targets.filter { names.contains($0.name) }
        for target in targets {
            removeFilesBottomUp(files: target.sourcesFiles, excludeFiles: excludeFiles)
            removeFilesBottomUp(files: target.resourcesFiles, excludeFiles: excludeFiles)
        }
    }
}
