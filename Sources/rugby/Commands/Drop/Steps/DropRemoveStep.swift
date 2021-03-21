//
//  DropRemoveStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files
import RegEx
import XcodeProj

final class DropRemoveStep: Step {

    init(logFile: File, verbose: Bool) {
        super.init(name: "Drop", logFile: logFile, verbose: verbose)
    }

    func run(project: String, targets: [String], products: Set<String>, keepSources: Bool) throws {
        guard !targets.isEmpty else {
            progress.update(info: "Can't find any targets. Skip".yellow)
            return done()
        }

        let podsProject = try XcodeProj(pathString: project)
        if !keepSources {
            progress.update(info: "Remove sources & resources".yellow)
            try targets.forEach { try removeSources(project: podsProject.pbxproj, fromTarget: $0) }
        }

        progress.update(info: "Remove targets".yellow)
        let removedTargets = Set(targets.filter(podsProject.pbxproj.removeTarget))

        progress.update(info: "Remove dependencies".yellow)
        removedTargets.forEach { podsProject.pbxproj.removeDependency(name: $0) }

        progress.update(info: "Remove schemes".yellow)
        try SchemeCleaner().removeSchemes(pods: removedTargets, projectPath: project)

        progress.update(info: "Update configs".yellow)
        try DropUpdateConfigs(products: products).removeProducts()

        progress.update(info: "Removed targets ".yellow + "(\(removedTargets.count))" + ":".yellow)
        removedTargets.caseInsensitiveSorted().forEach { progress.update(info: "* ".red + "\($0)") }

        progress.update(info: "Save project".yellow)
        try podsProject.write(pathString: project, override: true)

        done()
    }

    // Need to verify if some files for removing depends on remaining targets
    private func findFilesRemainingTargets(project: PBXProj, targetsForRemove: Set<String>) throws -> Set<String> {
        func collectFiles(targets: [PBXTarget]) throws -> Set<String> {
            try targets.reduce(into: []) { set, target in
                for file in try target.sourcesBuildPhase()?.files ?? [] {
                    guard let uuid = file.file?.uuid else { continue }
                    set.insert(uuid)
                }
                for file in try target.resourcesBuildPhase()?.files ?? [] {
                    guard let uuid = file.file?.uuid else { continue }
                    set.insert(uuid)
                }
            }
        }

        let allTargets = project.main.targets
        let remainingTargets = allTargets.filter { targetsForRemove.contains($0.name) }
        let remainingFiles = try collectFiles(targets: remainingTargets)
        let removingTargets = allTargets.filter { !targetsForRemove.contains($0.name) }
        let removingFiles = try collectFiles(targets: removingTargets)
        return remainingFiles.intersection(removingFiles)
    }

    private func removeSources(project: PBXProj, fromTarget name: String, excludeFiles: Set<String>) throws {
        guard let target = project.targets(named: name).first else { return }
        try target.sourcesBuildPhase()?.files?.removeFilesBottomUp(project: project, excludeFiles: excludeFiles)
        try target.resourcesBuildPhase()?.files?.removeFilesBottomUp(project: project, excludeFiles: excludeFiles)
    }

    @discardableResult
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
