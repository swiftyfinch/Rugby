//
//  XcodeProj+RemoveSources.swift
//  
//
//  Created by Vyacheslav Khorkov on 11.04.2021.
//

import XcodeProj

extension XcodeProj {
    func removeSources(pods: Set<String>) -> Bool {
        guard let podsGroup = pbxproj.groups.first(where: { $0.name == .podsGroup && $0.parent?.parent == nil }) else {
            return false
        }
        removeFilesRecursively(fromFile: podsGroup, pods: pods)
        if podsGroup.children.isEmpty {
            pbxproj.delete(object: podsGroup)
            (podsGroup.parent as? PBXGroup)?.children.removeAll { $0.name == .podsGroup }
        }
        return true
    }
}

extension XcodeProj {
    func removeSources(fromTargets names: Set<String>, excludeFiles: Set<String>) throws {
        let targets = pbxproj.main.targets.filter { names.contains($0.name) }
        for target in targets {
            removeFilesBottomUp(files: target.sourcesFiles, excludeFiles: excludeFiles)
            removeFilesBottomUp(files: target.resourcesFiles, excludeFiles: excludeFiles)
        }
    }
}
