//
//  PBXProj+RemoveDependency.swift
//  
//
//  Created by v.khorkov on 30.01.2021.
//

import XcodeProj

extension XcodeProj {
    @discardableResult
    func removeDependencies(names: Set<String>) -> Bool {
        var hasChanges = false
        for target in pbxproj.main.targets {
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
