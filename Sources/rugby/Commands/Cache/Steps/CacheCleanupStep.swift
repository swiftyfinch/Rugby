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
        hasChanges = podsProject.removeFrameworks(products: products) || hasChanges

        progress.update(info: "Remove products".yellow)
        if podsProject.removeFrameworkPaths(products: products) {
            hasChanges = true
        }

        progress.update(info: "Remove build target".yellow)
        if let target = input.scheme, podsProject.removeTarget(name: target) {
            hasChanges = true
        }

        progress.update(info: "Remove builded pods".yellow)
        var removeBuildedPods = podsProject.removeDependencies(names: remotePods)
        remotePods.forEach {
            removeBuildedPods = podsProject.removeTarget(name: $0) || removeBuildedPods
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
}
