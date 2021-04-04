//
//  CacheCleanupStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import XcodeProj

final class CacheCleanupStep: Step {
    let name = "Clean up"
    let verbose: Bool
    let isLast: Bool
    let progress: RugbyProgressBar

    private let command: Cache

    init(command: Cache, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyProgressBar(title: name, logFile: logFile, verbose: verbose)
    }

    func run(_ input: CachePrepareStep.Output) throws {
        let (remotePods, products) = (input.remotePods, input.products)
        var hasChanges = false
        let podsProject = try XcodeProj(pathString: .podsProject)

        if !command.keepSources {
            progress.update(info: "Remove sources from project".yellow)
            hasChanges = removeSources(project: podsProject.pbxproj, pods: remotePods) || hasChanges
        }

        progress.update(info: "Remove frameworks".yellow)
        products.forEach {
            hasChanges = podsProject.pbxproj.removeFrameworks(productName: $0) || hasChanges
        }

        progress.update(info: "Remove products".yellow)
        if removeFrameworkPaths(project: podsProject.pbxproj, groups: ["Frameworks", "Products"], products: products) {
            hasChanges = true
        }

        progress.update(info: "Remove build target".yellow)
        if let target = input.scheme, podsProject.pbxproj.removeTarget(name: target) {
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
            try podsProject.removeSchemes(pods: remotePods, projectPath: .podsProject)

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
