//
//  DropRemoveStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files

struct DropRemoveStep: Step {
    struct Input {
        let targets: Set<String>
        let products: Set<String>
        let testFlight: Bool
        let project: String
        let keepSources: Bool
    }

    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let metrics: Metrics

    init(verbose: Bool, metrics: Metrics, logFile: File, isLast: Bool = false) {
        self.metrics = metrics
        self.verbose = verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Drop", logFile: logFile, verbose: verbose)
    }

    func run(_ input: Input) throws {
        if input.testFlight {
            progress.print("Skip".yellow)
            return done()
        }

        let (targets, products) = (input.targets, input.products)
        guard !targets.isEmpty else {
            progress.print("Can't find any targets. Skip".yellow)
            return done()
        }

        let project = try ProjectProvider.shared.readProject(input.project)

        progress.print("Remove frameworks".yellow)
        project.removeFrameworks(products: products)

        progress.print("Remove dependencies".yellow)
        project.removeDependencies(names: targets)

        progress.print("Remove products".yellow)
        project.removeAppExtensions(products: products)
        project.removeFrameworkPaths(products: products)

        if !input.keepSources {
            progress.print("Remove sources & resources".yellow)
            let filesRemainingTargets = try project.findFilesRemainingTargets(targetsForRemove: targets)
            try project.removeSources(fromTargets: targets, excludeFiles: filesRemainingTargets)
        }

        progress.print("Remove schemes".yellow)
        try project.removeSchemes(pods: targets, projectPath: input.project)

        progress.print("Remove targets".yellow)
        let removedTargets = Set(targets.filter(project.removeTarget))

        progress.print("Update configs ⏱".yellow)
        try DropUpdateConfigs(products: products).removeProducts()

        progress.print(removedTargets, text: "Removed targets", deletion: true)

        progress.print("Save project ⏱".yellow)
        try project.write(pathString: input.project, override: true)
        metrics.projectSize.after = (try Folder.current.subfolder(at: input.project)).size()
        metrics.compileFilesCount.after = project.pbxproj.buildFiles.count
        if !input.testFlight { metrics.targetsCount.after = project.pbxproj.main.targets.count }

        return done()
    }
}
