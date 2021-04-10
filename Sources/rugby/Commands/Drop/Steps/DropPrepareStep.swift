//
//  DropPrepareStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files
import RegEx
import XcodeProj

final class DropPrepareStep: Step {
    struct Output {
        let foundTargets: Set<String>
        let products: Set<String>
    }

    let verbose: Bool
    let isLast: Bool
    let progress: RugbyProgressBar

    private let command: Drop
    private let metrics: Drop.Metrics

    init(command: Drop, metrics: Drop.Metrics, logFile: File, isLast: Bool = false) {
        self.command = command
        self.metrics = metrics
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyProgressBar(title: "Prepare", logFile: logFile, verbose: verbose)
    }

    func run(_ input: Void) throws -> Output {
        progress.update(info: "Find targets ".yellow)
        let exclude = Set(command.exclude)
        let regEx = try RegEx(pattern: "(" + command.targets.joined(separator: "|") + ")")
        let project = try XcodeProj(pathString: command.project)
        let foundTargets = project.targets.filter {
            if exclude.contains($0.name) { return false }
            let passedRegEx = regEx.test($0.name)
            return command.invert ? !passedRegEx : passedRegEx
        }
        progress.output(foundTargets.map(\.name), text: "Found targets")

        metrics.collect(removedTargets: command.testFlight ? 0 : foundTargets.count,
                        targets: project.targets.count)
        defer { done() }

        let products = Set(foundTargets.compactMap(\.product?.displayName))
        return Output(foundTargets: Set(foundTargets.map(\.name)), products: products)
    }
}
