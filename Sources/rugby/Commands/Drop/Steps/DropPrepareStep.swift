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
        let targetsCount: Int
    }

    init(logFile: File, verbose: Bool) {
        super.init(name: "Prepare", logFile: logFile, verbose: verbose)
    }

    func run(project: String, targets: [String], exclude: [String]) throws -> Output {
        let podsProject = try XcodeProj(pathString: project)
        let projectTargets = podsProject.pbxproj.main.targets

        progress.update(info: "Find targets ".yellow)
        let exclude = Set(exclude)
        let regEx = try RegEx(pattern: "(" + targets.joined(separator: "|") + ")")
        let foundTargets = projectTargets.filter {
            !exclude.contains($0.name) && regEx.test($0.name)
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
