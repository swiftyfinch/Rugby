//
//  DropRemoveStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files
import XcodeProj

final class DropRemoveStep: Step {
    let verbose: Bool
    let isLast: Bool
    let progress: RugbyProgressBar

    private let command: Drop

    init(command: Drop, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyProgressBar(title: "Drop", logFile: logFile, verbose: verbose)
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
        project.removeFrameworks(products: products)

        progress.update(info: "Remove dependencies".yellow)
        project.removeDependencies(names: targets)

        progress.update(info: "Remove products".yellow)
        project.removeAppExtensions(products: products)
        project.removeFrameworkPaths(products: products)

        if !command.keepSources {
            progress.update(info: "Remove sources & resources".yellow)
            let filesRemainingTargets = try project.findFilesRemainingTargets(targetsForRemove: Set(targets))
            try project.removeSources(fromTargets: targets, excludeFiles: filesRemainingTargets)
        }

        progress.update(info: "Remove schemes".yellow)
        try project.removeSchemes(pods: Set(targets), projectPath: command.project)

        progress.update(info: "Remove targets".yellow)
        let removedTargets = Set(targets.filter(project.removeTarget))

        progress.update(info: "Update configs".yellow)
        try DropUpdateConfigs(products: products).removeProducts()

        progress.output(removedTargets, text: "Removed targets", deletion: true)

        progress.update(info: "Save project".yellow)
        try project.write(pathString: command.project, override: true)

        return done()
    }
}
