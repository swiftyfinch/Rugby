//
//  DropPrepareStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files

struct DropPrepareStep: Step {
    let verbose: Int
    let isLast: Bool
    let progress: Printer

    private let command: Drop
    private let metrics: Metrics

    init(command: Drop, metrics: Metrics, logFile: File, isLast: Bool = false) {
        self.command = command
        self.metrics = metrics
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Prepare", logFile: logFile, verbose: verbose)
    }

    func run(_ input: Void) throws -> (foundTargets: Set<String>, products: Set<String>) {
        progress.print("Read project ⏱".yellow)
        metrics.projectSize.before = (try Folder.current.subfolder(at: command.project)).size()
        let project = try ProjectProvider.shared.readProject(command.project)
        metrics.compileFilesCount.before = project.pbxproj.buildFiles.count

        progress.print("Find targets".yellow)
        progress.print(command.exclude, text: "Exclude")
        let exclude = Set(command.exclude)
        let regex = try ("(" + command.targets.joined(separator: "|") + ")").regex()
        let foundTargets = project.targets.filter {
            if exclude.contains($0.name) { return false }
            let passedRegEx = $0.name.match(regex)
            return command.invert ? !passedRegEx : passedRegEx
        }
        progress.print(foundTargets.map(\.name), text: "Found targets")

        if !command.testFlight { metrics.targetsCount.before = project.pbxproj.main.targets.count }
        defer { done() }
        let products = Set(foundTargets.compactMap(\.product?.displayName))
        return Output(foundTargets: Set(foundTargets.map(\.name)), products: products)
    }
}
