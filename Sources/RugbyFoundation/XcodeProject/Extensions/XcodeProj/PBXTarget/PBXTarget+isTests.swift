//
//  PBXTarget+isTests.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 29.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXTarget {
    /// Checks if target is tests bundle or tests AppHost
    var isTests: Bool {
        let isUnitTests = (productType == .unitTestBundle)
        let isUITests = (productType == .uiTestBundle)
        let isTestsAppHost = (productType == .application) && name.contains("AppHost")
        return isUnitTests || isUITests || isTestsAppHost
    }
}
