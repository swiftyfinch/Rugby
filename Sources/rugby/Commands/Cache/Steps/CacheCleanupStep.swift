//
//  CacheCleanupStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import XcodeProj

struct CacheCleanupStep: Step {
    struct Input {
        let scheme: String?
        let pods: Set<String>
        let products: Set<String>
    }

    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let command: Cache

    init(command: Cache, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Clean up", logFile: logFile, verbose: verbose)
    }

    func run(_ input: Input) throws {
        let (remotePods, products) = (input.pods, input.products)
        var hasChanges = false
        let podsProject = try XcodeProj(pathString: .podsProject)

        if !command.keepSources {
            progress.print("Remove sources from project".yellow)
            hasChanges = podsProject.removeSources(pods: remotePods) || hasChanges
        }

        progress.print("Remove frameworks".yellow)
        hasChanges = podsProject.removeFrameworks(products: products) || hasChanges

        progress.print("Remove products".yellow)
        if podsProject.removeFrameworkPaths(products: products) {
            hasChanges = true
        }

        progress.print("Remove build target".yellow)
        if let target = input.scheme, podsProject.removeTarget(name: target) {
            hasChanges = true
        }

        progress.print("Remove builded pods".yellow)
        var removeBuildedPods = podsProject.removeDependencies(names: remotePods)
        remotePods.forEach {
            removeBuildedPods = podsProject.removeTarget(name: $0) || removeBuildedPods
        }

        if hasChanges || removeBuildedPods {
            // Remove schemes if has changes (it should be changes in targets)
            progress.print("Remove schemes".yellow)
            try podsProject.removeSchemes(pods: remotePods, projectPath: .podsProject)

            progress.print("Save project".yellow)
            try podsProject.write(pathString: .podsProject, override: true)
        }

        done()
    }
}
