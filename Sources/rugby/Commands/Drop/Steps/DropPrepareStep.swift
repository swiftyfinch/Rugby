//
//  DropPrepareStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files
import RegEx
import XcodeProj

final class DropPrepareStep: NewStep {
    struct Output {
        let foundTargets: [String]
        let products: Set<String>
        let targetsCount: Int
    }

    let name = "Prepare"
    let command: Drop
    let verbose: Bool
    let isLast: Bool
    let progress: RugbyProgressBar

    init(command: Drop, logFile: File, isLast: Bool) {
        self.command = command
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

        done()
        return Output(foundTargets: foundTargets.map(\.name),
                      products: products,
                      targetsCount: projectTargets.count)
    }
}
