//
//  XcodeProj+RemoveAppExtensions.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension XcodeProj {
    func removeAppExtensions(products: Set<String>) {
        let appExtensionsProducts = Set(products.filter { $0.hasSuffix("appex") })

        for target in pbxproj.main.targets {
            target.buildPhases.removeAll { phase in
                guard phase.name() == .appExtensionsPhase else { return false }

                phase.files?.removeAll {
                    guard let displayName = $0.file?.displayName else { return false }
                    guard appExtensionsProducts.contains(displayName) else { return false }
                    pbxproj.delete(object: $0)
                    return true
                }

                if (phase.files ?? []).isEmpty {
                    pbxproj.delete(object: phase)
                    return true
                }

                return false
            }
        }
    }
}

private extension String {
    static let appExtensionsPhase = "Embed App Extensions"
}
