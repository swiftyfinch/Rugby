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
        let foundTargets: [String]
        let products: Set<String>
    }

    let name = "Prepare"
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
        self.progress = RugbyProgressBar(title: name, logFile: logFile, verbose: verbose)
    }

    func run(_ input: Void) throws -> Output {
        let podsProject = try XcodeProj(pathString: command.project)
        let projectTargets = podsProject.pbxproj.main.targets

        progress.update(info: "Find targets ".yellow)
        let exclude = Set(command.exclude)
        let regEx = try RegEx(pattern: "(" + command.targets.joined(separator: "|") + ")")
        let foundTargets = projectTargets.filter {
            if exclude.contains($0.name) { return false }
            let passedRegEx = regEx.test($0.name)
            return command.invert ? !passedRegEx : passedRegEx
        }

        progress.update(info: "Found targets ".yellow + "(\(foundTargets.count))" + ":".yellow)
        foundTargets.map(\.name).caseInsensitiveSorted().forEach { progress.update(info: "* ".yellow + "\($0)") }

        // Prepare list of products like: Some.framework, Some.bundle
        let products = Set(foundTargets.compactMap(\.product?.displayName))

        metrics.removedTargets = foundTargets.count
        metrics.targets = projectTargets.count

        done()
        return Output(foundTargets: foundTargets.map(\.name),
                      products: products)
    }
}
