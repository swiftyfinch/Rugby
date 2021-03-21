//
//  CacheCleanupStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import ShellOut
import XcodeProj

final class CacheCleanupStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Clean up", logFile: logFile, verbose: verbose)
    }

    func run(remotePods: Set<String>,
             buildTarget: String,
             keepSources: Bool,
             products: Set<String>) throws {
        var hasChanges = false
        let podsProject = try XcodeProj(pathString: .podsProject)

        if !keepSources {
            progress.update(info: "Remove sources from project".yellow)
            hasChanges = removeSources(project: podsProject.pbxproj, pods: remotePods) || hasChanges
        }

        progress.update(info: "Remove products".yellow)
        if removeFrameworkPaths(project: podsProject.pbxproj, groups: ["Frameworks", "Products"], products: products) {
            hasChanges = true
        }

        progress.update(info: "Remove build target".yellow)
        if podsProject.pbxproj.removeTarget(name: buildTarget) {
            hasChanges = true
        }

        progress.update(info: "Remove builded pods".yellow)
        var removeBuildedPods = false
        remotePods.forEach {
            removeBuildedPods = podsProject.pbxproj.removeDependency(name: $0) || removeBuildedPods
            removeBuildedPods = podsProject.pbxproj.removeTarget(name: $0) || removeBuildedPods
        }

        if hasChanges || removeBuildedPods {
            // Remove schemes if has changes (it should be changes in targets)
            progress.update(info: "Remove schemes".yellow)
            try SchemeCleaner().removeSchemes(pods: remotePods, projectPath: .podsProject)

            progress.update(info: "Save project".yellow)
            try podsProject.write(pathString: .podsProject, override: true)
        }

        done()
    }

    private func removeSources(project: PBXProj, pods: Set<String>) -> Bool {
        guard let podsGroup = project.groups.first(where: { $0.name == .podsGroup && $0.parent?.parent == nil }) else {
            return false
        }
        podsGroup.removeFilesRecursively(from: project, pods: pods)
        if podsGroup.children.isEmpty {
            project.delete(object: podsGroup)
            (podsGroup.parent as? PBXGroup)?.children.removeAll { $0.name == .podsGroup }
        }
        return true
    }

    private func removeFrameworkPaths(project: PBXProj, groups: Set<String>, products: Set<String>) -> Bool {
        var hasChanges = false
        let frameworks = project.groups.filter {
            ($0.name.map(groups.contains) ?? false) && $0.parent?.parent == nil
        }
        frameworks.forEach {
            $0.children.forEach { child in
                if let name = child.name, products.contains(name) {
                    project.delete(object: child)
                    (child.parent as? PBXGroup)?.children.removeAll(where: { child.uuid == $0.uuid })
                    hasChanges = true
                } else if let path = child.path, products.contains(path) {
                    project.delete(object: child)
                    (child.parent as? PBXGroup)?.children.removeAll(where: { child.uuid == $0.uuid })
                    hasChanges = true
                }
            }
        }
        return hasChanges
    }
}
