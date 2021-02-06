//
//  CleanupStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import XcodeProj

final class CleanupStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Clean up", logFile: logFile, verbose: verbose)
    }

    func run(buildPods: Set<String>, buildTarget: String) throws {
        let podsProject = try XcodeProj(pathString: .podsProject)
        if !buildPods.isEmpty {
            podsProject.pbxproj.removeTarget(name: buildTarget)
            progress.update(info: "Remove aggregated build target".yellow)
        }
        buildPods.forEach {
            podsProject.pbxproj.removeDependency(name: $0)
            podsProject.pbxproj.removeTarget(name: $0)
        }
        progress.update(info: "Remove builded pods".yellow)

        try podsProject.write(pathString: .podsProject, override: true)
        progress.update(info: "Save project".yellow)

        done()
    }
}
