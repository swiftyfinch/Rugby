//
//  PrepareStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import XcodeProj
import Files

final class PrepareStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Prepare", logFile: logFile, verbose: verbose)
    }

    func run(buildTarget: String, needRebuild: Bool) throws -> (buildPods: [String], checksums: [String], remotePods: [String]) {
        let podfile = try Podfile(.podfileLock)
        let remotePods = try podfile.getRemotePods()
        progress.update(info: "Found remote pods ".yellow + "(\(remotePods.count))" + ":".yellow)
        remotePods.forEach { progress.update(info: "* ".yellow + "\($0)") }

        let checksums = try podfile.getChecksums().filter {
            guard let name = $0.components(separatedBy: ": ").first else { return false }
            return remotePods.contains(name)
        }

        let buildPods: [String]
        if needRebuild {
            buildPods = remotePods
        } else {
            let cachedChecksums = (try? Podfile(.cachedChecksums).getChecksums()) ?? []
            let changes = Set(checksums).subtracting(cachedChecksums)
            let changedPods = changes.compactMap { $0.components(separatedBy: ": ").first }
            changedPods.forEach { print($0) }
            buildPods = changedPods
        }

        let podsProject = try XcodeProj(pathString: .podsProject)
        if !buildPods.isEmpty {
            podsProject.pbxproj.addTarget(name: buildTarget, dependencies: buildPods)
            progress.update(info: "Added tmp target: ".yellow + buildTarget)
            try podsProject.write(pathString: .podsProject, override: true)
        }
        done()

        return (buildPods, checksums, remotePods)
    }
}
