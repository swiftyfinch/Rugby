//
//  DropRemoveStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files
import XcodeProj

struct DropRemoveStep: Step {
    struct Input {
        let targets: Set<String>
        let products: Set<String>
    }

    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let command: Drop

    init(command: Drop, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Drop", logFile: logFile, verbose: verbose)
    }

    func run(_ input: Input) throws {
        if command.testFlight {
            progress.print("Skip".yellow)
            return done()
        }

        let (targets, products) = (input.targets, input.products)
        guard !targets.isEmpty else {
            progress.print("Can't find any targets. Skip".yellow)
            return done()
        }

        let project = try XcodeProj(pathString: command.project)

        progress.print("Remove frameworks".yellow)
        project.removeFrameworks(products: products)

        progress.print("Remove dependencies".yellow)
        project.removeDependencies(names: targets)

        progress.print("Remove products".yellow)
        project.removeAppExtensions(products: products)
        project.removeFrameworkPaths(products: products)

        if !command.keepSources {
            progress.print("Remove sources & resources".yellow)
            let filesRemainingTargets = try project.findFilesRemainingTargets(targetsForRemove: Set(targets))
            try project.removeSources(fromTargets: targets, excludeFiles: filesRemainingTargets)
        }

        progress.print("Remove schemes".yellow)
        try project.removeSchemes(pods: Set(targets), projectPath: command.project)

        progress.print("Remove targets".yellow)
        let removedTargets = Set(targets.filter(project.removeTarget))

        progress.print("Update configs ⏱".yellow)
        try DropUpdateConfigs(products: products).removeProducts()

        progress.print(removedTargets, text: "Removed targets", deletion: true)

        progress.print("Save project ⏱".yellow)
        try project.write(pathString: command.project, override: true)

        return done()
    }
}
