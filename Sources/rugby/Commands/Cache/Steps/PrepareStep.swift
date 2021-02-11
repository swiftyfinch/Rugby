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

    func run(buildTarget: String,
             needRebuild: Bool) throws -> (buildPods: [String], remotePods: Set<String>, checksums: [String]) {
        // Get remote pods from Podfile.lock
        let podfile = try Podfile(.podfileLock)
        let remotePods = try podfile.getRemotePods().map { $0.trimmingCharacters(in: ["\""]) }
        progress.update(info: "Remote pods ".yellow + "(\(remotePods.count))" + ":".yellow)
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
            buildPods = changedPods.sorted()
        }
        progress.update(info: "Build pods ".yellow + "(\(buildPods.count))" + ":".yellow)
        buildPods.forEach { progress.update(info: "* ".yellow + "\($0)") }

        // Validate pods
        let podsProject = try XcodeProj(pathString: .podsProject)
        let missedPods = buildPods.filter { podsProject.pbxproj.targets(named: $0).isEmpty }
        if !missedPods.isEmpty {
            throw CacheError.cantFindPodsInProject(missedPods)
        }

        // Collect all remote pods chain
        let remotePodsChain: Set<String> = remotePods.reduce(Set(remotePods)) { set, name in
            let targets = Set(podsProject.pbxproj.targets(named: name))
            return set.union(targets.reduce(Set<String>()) { set, target in
                return set.union(target.dependencies.compactMap(\.name))
            })
        }
        let additionalBuildTargets = remotePodsChain.subtracting(remotePods)
        if !additionalBuildTargets.isEmpty {
            progress.update(info: "Additional build targets ".yellow + "(\(additionalBuildTargets.count))" + ":".yellow)
            additionalBuildTargets.sorted().forEach { progress.update(info: "* ".yellow + "\($0)") }
        }

        if buildPods.isEmpty {
            progress.update(info: "Skip".yellow)
        } else {
            podsProject.pbxproj.addTarget(name: buildTarget, dependencies: buildPods)
            progress.update(info: "Added aggregated build target: ".yellow + buildTarget)
            try podsProject.write(pathString: .podsProject, override: true)
        }
        done()

        return (buildPods, remotePodsChain, checksums)
    }
}
