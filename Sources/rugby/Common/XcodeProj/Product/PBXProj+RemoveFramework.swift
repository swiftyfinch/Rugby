//
//  PBXProj+RemoveFramework.swift
//  
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//

import XcodeProj

extension PBXProj {
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
