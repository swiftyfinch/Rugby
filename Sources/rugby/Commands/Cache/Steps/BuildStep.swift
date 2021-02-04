//
//  BuildStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import XcodeProj

final class BuildStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Build", logFile: logFile, verbose: verbose)
    }

    func run(scheme: String?, checksums: [String]) throws {
        if let scheme = scheme {
            progress.update(info: "Building...".yellow)
            try XcodeBuild(project: .podsProject, scheme: scheme).build()
            do {
                try XcodeBuild(project: .podsProject, scheme: scheme).build()
            } catch {
                let podsProject = try XcodeProj(pathString: .podsProject)
                podsProject.pbxproj.removeTarget(name: scheme)
                try podsProject.write(pathString: .podsProject, override: true)
                throw error
            }
            progress.update(info: "Finish".yellow)
            
            let checksumsFile = try Folder.current.createFileIfNeeded(at: .cachedChecksums)
            try checksumsFile.write("SPEC CHECKSUMS:\n" + checksums.joined(separator: "\n") + "\n\n")
            progress.update(info: "Update checksums".yellow)
        } else {
            progress.update(info: "Skip".yellow)
        }
        done()
    }
}
