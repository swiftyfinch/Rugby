//
//  FocusPrepareStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//

import Files
import RegEx
import XcodeProj

struct FocusPrepareStep: Step {
    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let command: Focus
    private let metrics: Metrics

    init(command: Focus, metrics: Metrics, logFile: File, isLast: Bool = false) {
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
