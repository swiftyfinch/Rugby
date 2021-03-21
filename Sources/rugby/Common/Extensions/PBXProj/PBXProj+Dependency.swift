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
                guard $0.displayName == name else { return false }
                delete(object: $0)
                $0.targetProxy.map(delete)
                hasChanges = true
                return true
            }
        }
        return hasChanges
    }

    @discardableResult
    func removeFrameworks(productName: String) -> Bool {
        var hasChanges = false
        for target in main.targets {
            try? target.frameworksBuildPhase()?.files?.removeAll {
                guard $0.file?.displayName == productName else { return false }
                delete(object: $0)
                hasChanges = true
                return true
            }
        }
        return hasChanges
    }
}

extension PBXTargetDependency {
    var displayName: String? {
        name ?? target?.name
    }
}
