//
//  XcodeProj+BuildRemotePodsChain.swift
//  
//
//  Created by Vyacheslav Khorkov on 08.04.2021.
//

import XcodeProj

extension XcodeProj {
    func buildRemotePodsChain(remotePods: Set<String>) -> Set<PBXTarget> {
        remotePods.reduce(into: Set<PBXTarget>()) { chain, name in
            let targets = Set(pbxproj.targets(named: name))
            chain.formUnion(targets)

            let dependencies = targets.reduce(Set<PBXTarget>()) { set, target in
                let dependencies = target.dependencies.filter {
                    // Check that it's a part of remote pod
                    guard let prefix = $0.name?.components(separatedBy: "-").first else { return true }
                    return remotePods.contains(prefix)
                }
                return set.union(dependencies.compactMap(\.target))
            }
            chain.formUnion(dependencies)
        }
    }
}
