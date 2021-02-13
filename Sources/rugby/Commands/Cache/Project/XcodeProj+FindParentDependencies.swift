//
//  File.swift
//  
//
//  Created by Vyacheslav Khorkov on 13.02.2021.
//

import XcodeProj

extension XcodeProj {
    // Maybe will be better to make tree for better performance.
    // But for now, don't see easier way to get target parents.
    func findParentDependencies(_ usedTargets: Set<String>, allTargets: [String]) -> [String] {
        var hasChanges = false
        var used = usedTargets
        repeat {
            hasChanges = false
            for pod in allTargets where !used.contains(pod) {
                guard let first = pbxproj.targets(named: pod).first else { continue }
                let dependencies = first.dependencies.compactMap(\.name)
                guard dependencies.contains(where: { used.contains($0) }) else { continue }
                used.insert(first.name)
                hasChanges = true
            }
        } while hasChanges
        return Array(used)
    }
}
