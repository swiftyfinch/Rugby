//
//  XcodeProj+RemoveSources.swift
//  
//
//  Created by Vyacheslav Khorkov on 11.04.2021.
//

import XcodeProj

extension XcodeProj {
    @discardableResult
    func removeSources(pods: Set<String>, fromGroup groupName: String) -> Bool {
        guard let group = pbxproj.groups.first(where: { $0.name == groupName && $0.parent?.parent == nil }) else {
            return false
        }
        removeFilesRecursively(fromFile: group, rootGroup: groupName, pods: pods)
        if group.children.isEmpty {
            pbxproj.delete(object: group)
            (group.parent as? PBXGroup)?.children.removeAll { $0.name == groupName }
        }
        return true
    }
}

extension XcodeProj {
    func removeSources(fromTargets names: Set<String>, excludeFiles: Set<String> = []) throws {
        let targets = pbxproj.main.targets.filter { names.contains($0.name) }
        for target in targets {
            removeFilesBottomUp(files: target.sourcesFiles, excludeFiles: excludeFiles)
            removeFilesBottomUp(files: target.resourcesFiles, excludeFiles: excludeFiles)
        }
    }
}
