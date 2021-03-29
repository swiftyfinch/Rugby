//
//  CacheBuildStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import XcodeProj

final class CacheBuildStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Build", logFile: logFile, verbose: verbose)
    }

    func run(scheme: String?, checksums: [String], command: Cache) throws {
        if let scheme = scheme {
            progress.update(info: "Building ⏱".yellow)
            do {
                try XcodeBuild(project: .podsProject, scheme: scheme, sdk: command.sdk, arch: command.arch).build()
            } catch {
                let podsProject = try XcodeProj(pathString: .podsProject)
                podsProject.pbxproj.removeTarget(name: scheme)
                try podsProject.write(pathString: .podsProject, override: true)
                progress.update(info: "Full build log: ".yellow + .buildLog)
                throw error
            }
            progress.update(info: "Finish".yellow)

            progress.update(info: "Update checksums".yellow)
            try CacheManager().save(CacheFile(checksums: checksums, sdk: command.sdk, arch: command.arch))
        } else {
            progress.update(info: "Skip".yellow)
        }
        done()
    }
}
