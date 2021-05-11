//
//  XcodeProj+RemoveDependency.swift
//  
//
//  Created by v.khorkov on 30.01.2021.
//

import XcodeProj

extension XcodeProj {
    @discardableResult
    func removeDependencies(names: Set<String>, exclude: [String] = []) -> Bool {
        var hasChanges = false
        for target in pbxproj.main.targets {
            addTransitiveDependenciesExplicitly(target: target, exclude: exclude)
            target.dependencies.removeAll {
                guard let displayName = $0.displayName else { return false }
                guard names.contains(displayName) else { return false }
                pbxproj.delete(object: $0)
                $0.targetProxy.map(pbxproj.delete)
                hasChanges = true
                return true
            }
        }
        return hasChanges
    }
}

private extension XcodeProj {
    /// When excludes dependency which added as implicitly dependency (transitive)
    /// - Note: A -> B -> C and remove B, but exclude C. So, need to add C explicitly A -> C.
    func addTransitiveDependenciesExplicitly(target: PBXTarget, exclude: [String]) {
        guard !exclude.isEmpty else { return }
        let recursiveDependencies = target.recursiveDependencies().values
        let excludedDependencies = recursiveDependencies.filter { $0.displayName.map(exclude.contains) ?? false }
        guard !excludedDependencies.isEmpty else { return }

        for dependency in excludedDependencies {
            guard !target.dependencies.contains(where: { $0.displayName == dependency.displayName }) else { continue }
            let transitiveDependency = PBXTargetDependency(name: dependency.displayName, target: dependency.target)
            target.dependencies.append(transitiveDependency)
            pbxproj.add(object: transitiveDependency)
        }
    }
}
