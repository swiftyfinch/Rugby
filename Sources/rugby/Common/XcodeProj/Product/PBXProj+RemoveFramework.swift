//
//  PBXProj+RemoveFramework.swift
//  
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//

import XcodeProj

extension XcodeProj {
    @discardableResult
    func removeFrameworks(products: Set<String>) -> Bool {
        var hasChanges = false
        for target in pbxproj.main.targets {
            try? target.frameworksBuildPhase()?.files?.removeAll {
                guard let displayName = $0.file?.displayName else { return false }
                guard products.contains(displayName) else { return false }
                pbxproj.delete(object: $0)
                hasChanges = true
                return true
            }
        }
        return hasChanges
    }
}
