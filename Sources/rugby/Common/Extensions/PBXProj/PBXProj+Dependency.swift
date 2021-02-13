//
//  PBXProj+Dependency.swift
//  
//
//  Created by v.khorkov on 30.01.2021.
//

import XcodeProj

extension PBXProj {
    @discardableResult
    func removeDependency(name: String) -> Bool {
        var hasChanges = false
        for target in main.targets {
            target.dependencies.removeAll {
                guard $0.name == name else { return false }
                delete(object: $0)
                hasChanges = true
                return true
            }
        }
        return hasChanges
    }
}
