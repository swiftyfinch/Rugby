//
//  DropRemoveStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files
import RegEx
import XcodeProj

final class DropRemoveStep: NewStep {
    let name = "Drop"
    let command: Drop
    let verbose: Bool
    let isLast: Bool
    let progress: RugbyProgressBar

    init(command: Drop, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyProgressBar(title: name, logFile: logFile, verbose: verbose)
    }

    func run(_ input: DropPrepareStep.Output) throws {
        if command.testFlight {
            progress.update(info: "Skip".yellow)
            return done()
        }

        let (targets, products) = (input.foundTargets, input.products)

        guard !targets.isEmpty else {
            progress.update(info: "Can't find any targets. Skip".yellow)
            return done()
        }

        let project = try XcodeProj(pathString: command.project)

        progress.update(info: "Remove frameworks".yellow)
        products.forEach { project.pbxproj.removeFrameworks(productName: $0) }

        progress.update(info: "Remove dependencies".yellow)
        targets.forEach { project.pbxproj.removeDependency(name: $0) }

        // Remove app extension
        products.filter { $0.hasSuffix("appex") }.forEach {
            project.pbxproj.removeAppExtensions(productName: $0)
        }

        progress.update(info: "Remove products".yellow)
        removeFrameworkPaths(project: project.pbxproj, groups: ["Frameworks", "Products"], products: products)

        if !command.keepSources {
            progress.update(info: "Remove sources & resources".yellow)
            let filesRemainingTargets = try findFilesRemainingTargets(project: project.pbxproj,
                                                                      targetsForRemove: Set(targets))
            try targets.forEach { try removeSources(project: project.pbxproj,
                                                    fromTarget: $0,
                                                    excludeFiles: filesRemainingTargets) }
        }

        progress.update(info: "Remove schemes".yellow)
        try project.removeSchemes(pods: Set(targets), projectPath: command.project)

        progress.update(info: "Remove targets".yellow)
        let removedTargets = Set(targets.filter(project.pbxproj.removeTarget))

        progress.update(info: "Update configs".yellow)
        try DropUpdateConfigs(products: products).removeProducts()

        progress.update(info: "Removed targets ".yellow + "(\(removedTargets.count))" + ":".yellow)
        removedTargets.caseInsensitiveSorted().forEach { progress.update(info: "* ".red + "\($0)") }

        progress.update(info: "Save project".yellow)
        try project.write(pathString: command.project, override: true)

        return done()
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
