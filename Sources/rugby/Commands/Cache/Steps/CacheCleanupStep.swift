//
//  CacheCleanupStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import Foundation

struct CacheCleanupStep: Step {
    struct Input {
        let scheme: String?
        let targets: Set<String>
        let products: Set<String>
    }

    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let command: Cache
    private let metrics: Metrics

    init(command: Cache, metrics: Metrics, logFile: File, isLast: Bool = false) {
        self.command = command
        self.metrics = metrics
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Clean up", logFile: logFile, verbose: verbose)
    }

    func run(_ input: Input) throws {
        let (targets, products) = (input.targets, input.products)
        var hasChanges = false
        progress.print("Read project ⏱".yellow)
        let project = try ProjectProvider.shared.readProject(.podsProject)

        if !command.keepSources {
            progress.print("Remove sources from project".yellow)
            hasChanges = project.removeSources(pods: targets, fromGroup: .podsGroup) || hasChanges
            try project.removeSources(fromTargets: targets)
        }

        progress.print("Remove frameworks".yellow)
        hasChanges = project.removeFrameworks(products: products) || hasChanges

        progress.print("Remove products".yellow)
        if project.removeFrameworkPaths(products: products) {
            hasChanges = true
        }

        progress.print("Remove build target".yellow)
        if let target = input.scheme, project.removeTarget(name: target) {
            hasChanges = true
        }

        progress.print("Remove builded pods".yellow)
        var removeBuildedPods = project.removeDependencies(names: targets, exclude: command.exclude)
        targets.forEach {
            removeBuildedPods = project.removeTarget(name: $0) || removeBuildedPods
        }

        if hasChanges || removeBuildedPods {
            // Remove schemes if has changes (it should be changes in targets)
            progress.print("Remove schemes".yellow)
            try project.removeSchemes(pods: targets, projectPath: .podsProject)

            progress.print("Save project ⏱".yellow)
            try project.write(pathString: .podsProject, override: true)

            metrics.projectSize.after = (try Folder.current.subfolder(at: .podsProject)).size()
            metrics.compileFilesCount.after = project.pbxproj.buildFiles.count
            metrics.targetsCount.after = project.pbxproj.main.targets.count
        }

        done()
    }
}
