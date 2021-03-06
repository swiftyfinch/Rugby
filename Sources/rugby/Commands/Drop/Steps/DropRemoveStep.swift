//
//  DropRemoveStep.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import Files
import RegEx
import XcodeProj

final class DropRemoveStep: Step {

    init(logFile: File, verbose: Bool) {
        super.init(name: "Drop", logFile: logFile, verbose: verbose)
    }

    func run(project: String, targets: [String], products: Set<String>, keepSources: Bool) throws {
        guard !targets.isEmpty else {
            progress.update(info: "Can't find any targets. Skip".yellow)
            return done()
        }

        let podsProject = try XcodeProj(pathString: project)
        if !keepSources {
            progress.update(info: "Remove sources & resources".yellow)
            try targets.forEach { try removeSources(project: podsProject.pbxproj, fromTarget: $0) }
        }

        progress.update(info: "Remove targets".yellow)
        let removedTargets = Set(targets.filter(podsProject.pbxproj.removeTarget))

        progress.update(info: "Remove dependencies".yellow)
        removedTargets.forEach { podsProject.pbxproj.removeDependency(name: $0) }

        progress.update(info: "Remove schemes".yellow)
        try SchemeCleaner().removeSchemes(pods: removedTargets, projectPath: project)

        progress.update(info: "Update configs".yellow)
        try DropUpdateConfigs(products: products).removeProducts()

        progress.update(info: "Removed targets ".yellow + "(\(removedTargets.count))" + ":".yellow)
        removedTargets.caseInsensitiveSorted().forEach { progress.update(info: "* ".red + "\($0)") }

        progress.update(info: "Save project".yellow)
        try podsProject.write(pathString: project, override: true)

        done()
    }

    private func removeSources(project: PBXProj, fromTarget name: String) throws {
        guard let target = project.targets(named: name).first else { return }
        try target.sourcesBuildPhase()?.files?.removeFilesBottomUp(project: project)
        try target.resourcesBuildPhase()?.files?.removeFilesBottomUp(project: project)
    }
}
