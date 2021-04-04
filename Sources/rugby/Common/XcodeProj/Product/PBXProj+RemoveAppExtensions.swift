//
//  PBXProj+RemoveAppExtensions.swift
//  
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//

import XcodeProj

extension PBXProj {
    func removeAppExtensions(productName: String) {
        for target in main.targets {
            target.buildPhases.removeAll { phase in
                if phase.name() == "Embed App Extensions" {
                    phase.files?.removeAll {
                        guard $0.file?.displayName == productName else { return false }
                        delete(object: $0)
                        return true
                    }
                    if (phase.files ?? []).isEmpty {
                        delete(object: phase)
                        return true
                    }
                }
                return false
            }
        }
    }
}
