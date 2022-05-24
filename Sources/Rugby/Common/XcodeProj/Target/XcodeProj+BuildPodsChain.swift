//
//  XcodeProj+BuildPodsChain.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 08.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    func buildPodsChain(pods: Set<String>) -> Set<PBXTarget> {
        pods.reduce(into: Set<PBXTarget>()) { chain, name in
            let targets = findAllPodTargets(name)
            chain.formUnion(targets)

            let dependencies = targets.reduce(Set<PBXTarget>()) { set, target in
                let filteredDependencies = target.dependencies.filter {
                    // Check that it's a part of pod
                    guard let prefix = $0.name?.components(separatedBy: "-").first else { return true }
                    return pods.contains(prefix)
                }
                return set.union(filteredDependencies.compactMap(\.target))
            }
            chain.formUnion(dependencies)
        }
    }
}

private extension XcodeProj {
    /// Include subspecs
    func findAllPodTargets(_ name: String) -> Set<PBXTarget> {
        let targets = pbxproj.main.targets
        let filtered = targets.filter {
            if $0.name == name { return true }

            // Get all subspecs
            guard $0.name.hasPrefix(name + ".") || $0.name.hasPrefix(name + "-") else { return false }

            // But ignore all testspecs and its resources
            let suffix = String($0.name.dropFirst((name + ".").count))
            return !suffix.contains("Test")
        }
        return Set(filtered)
    }
}
