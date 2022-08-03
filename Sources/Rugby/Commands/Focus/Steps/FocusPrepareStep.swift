//
//  FocusPrepareStep.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import XcodeProj

struct FocusPrepareStep: Step {
    let verbose: Int
    let isLast: Bool
    let progress: Printer

    private let command: Focus
    private let metrics: Metrics

    init(command: Focus, metrics: Metrics, logFile: File, isLast: Bool = false) {
        self.command = command
        self.metrics = metrics
        self.verbose = command.flags.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Focus", logFile: logFile, verbose: verbose, quiet: command.flags.quiet, nonInteractive: command.flags.nonInteractive)
    }

    func run(_ input: Void) throws -> (foundTargets: Set<String>, products: Set<String>) {
        metrics.projectSize.before = (try Folder.current.subfolder(at: command.project)).size()

        let project = try progress.spinner("Read project") {
            try ProjectProvider.shared.readProject(command.project)
        }
        metrics.compileFilesCount.before = project.pbxproj.buildFiles.count

        progress.print("Find targets".yellow)
        let targets: Set<PBXTarget> = command.targets.reduce(into: []) { set, name in
            set.formUnion(project.pbxproj.targets(named: name))
        }
        let recursiveTargets = targets.reduce(into: targets) { set, target in
            set.formUnion(target.recursiveDependencies().values.compactMap(\.target))
        }
        let foundTargets = project.pbxproj.main.targets.filter { !recursiveTargets.contains($0) }
        progress.print(foundTargets.map(\.name), text: "Found targets")

        if !command.testFlight { metrics.targetsCount.before = project.pbxproj.main.targets.count }
        defer { done() }
        let products = Set(foundTargets.compactMap(\.product?.displayName))
        return Output(foundTargets: Set(foundTargets.map(\.name)), products: products)
    }
}
