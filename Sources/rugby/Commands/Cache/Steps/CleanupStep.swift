//
//  CleanupStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import XcodeProj
import ShellOut

final class CleanupStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Clean up", logFile: logFile, verbose: verbose)
    }

    func run(remotePods: Set<String>, buildTarget: String) throws {
        var hasChanges = false
        let podsProject = try XcodeProj(pathString: .podsProject)

        if podsProject.pbxproj.removeTarget(name: buildTarget) {
            hasChanges = true
            progress.update(info: "Remove aggregated build target".yellow)
        }

        remotePods.forEach {
            hasChanges = podsProject.pbxproj.removeDependency(name: $0) || hasChanges
            hasChanges = podsProject.pbxproj.removeTarget(name: $0) || hasChanges
        }
        progress.update(info: "Remove builded pods".yellow)

        let username = try shellOut(to: "echo ${USER}")
        let schemeCleaner = SchemeCleaner()
        remotePods.forEach {
            if (try? schemeCleaner.removeScheme(name: $0, user: username)) == nil {
                progress.update(info: "- Can't remove scheme \($0).".red)
            }
        }
        progress.update(info: "Remove schemes".yellow)

        if hasChanges {
            try podsProject.write(pathString: .podsProject, override: true)
            progress.update(info: "Save project".yellow)
        }

        done()
    }
}
