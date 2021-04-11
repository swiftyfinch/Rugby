//
//  XcodeProj+FindFilesRemainingTargets.swift
//  
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
//

import XcodeProj

extension XcodeProj {
    // Need to verify if some files for removing depends on remaining targets
    func findFilesRemainingTargets(targetsForRemove: Set<String>) throws -> Set<String> {
        func collectFiles(targets: [PBXTarget]) throws -> Set<String> {
            try targets.reduce(into: []) { set, target in
                for file in try target.sourcesBuildPhase()?.files ?? [] {
                    guard let uuid = file.file?.uuid else { continue }
                    set.insert(uuid)
                }
                for file in try target.resourcesBuildPhase()?.files ?? [] {
                    guard let uuid = file.file?.uuid else { continue }
                    set.insert(uuid)
                }
            }
        }

        let allTargets = pbxproj.main.targets
        let remainingTargets = allTargets.filter { targetsForRemove.contains($0.name) }
        let remainingFiles = try collectFiles(targets: remainingTargets)
        let removingTargets = allTargets.filter { !targetsForRemove.contains($0.name) }
        let removingFiles = try collectFiles(targets: removingTargets)
        return remainingFiles.intersection(removingFiles)
    }
}
