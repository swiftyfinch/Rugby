//
//  CleanupStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import ShellOut
import XcodeProj

final class CleanupStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Clean up", logFile: logFile, verbose: verbose)
    }

    func run(remotePods: Set<String>, buildTarget: String, dropSources: Bool, products: Set<String>) throws {
        var hasChanges = false
        let podsProject = try XcodeProj(pathString: .podsProject)

        if dropSources && removeSources(project: podsProject.pbxproj) {
            hasChanges = true
            progress.update(info: "Remove remote pods sources from project".yellow)
        }

        if restoreFrameworkPaths(project: podsProject.pbxproj, groups: ["Frameworks", "Products"], products: products) {
            hasChanges = true
            progress.update(info: "Remove remote pods products".yellow)
        }

        if podsProject.pbxproj.removeTarget(name: buildTarget) {
            hasChanges = true
            progress.update(info: "Remove aggregated build target".yellow)
        }

        var removeBuildedPods = false
        remotePods.forEach {
            removeBuildedPods = podsProject.pbxproj.removeDependency(name: $0) || removeBuildedPods
            removeBuildedPods = podsProject.pbxproj.removeTarget(name: $0) || removeBuildedPods
        }
        if removeBuildedPods { progress.update(info: "Remove builded pods".yellow) }

        if hasChanges || removeBuildedPods {
            // Remove schemes if has changes (it should be changes in targets)
            try removeSchemes(pods: remotePods)

            try podsProject.write(pathString: .podsProject, override: true)
            progress.update(info: "Save project".yellow)
        }

        done()
    }

    private func removeSchemes(pods: Set<String>) throws {
        let username = try shellOut(to: "echo ${USER}")
        let schemeCleaner = SchemeCleaner()
        pods.forEach { try? schemeCleaner.removeScheme(name: $0, user: username) }
        progress.update(info: "Remove schemes".yellow)
    }

    private func removeSources(project: PBXProj) -> Bool {
        guard let podsGroup = project.groups.first(where: { $0.name == "Pods" && $0.parent?.parent == nil }) else {
            return false
        }
        podsGroup.removeFilesRecursively(from: project)
        (podsGroup.parent as? PBXGroup)?.children.removeAll(where: { $0.name == "Pods" })
        return true
    }

    private func restoreFrameworkPaths(project: PBXProj, groups: Set<String>, products: Set<String>) -> Bool {
        var hasChanges = false
        let frameworks = project.groups.filter {
            ($0.name.map(groups.contains) ?? false) && $0.parent?.parent == nil
        }
        frameworks.forEach {
            $0.children.forEach { child in
                if let name = child.name, products.contains(name) {
                    project.delete(object: child)
                    (child.parent as? PBXGroup)?.children.removeAll(where: { child.name == $0.name })
                    hasChanges = true
                } else if let path = child.path, products.contains(path) {
                    project.delete(object: child)
                    (child.parent as? PBXGroup)?.children.removeAll(where: { child.name == $0.name })
                    hasChanges = true
                }
            }
        }
        return hasChanges
    }
}
