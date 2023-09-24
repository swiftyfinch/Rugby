//
//  PBXTarget+Product.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 27.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXTarget {
    func constructProduct(_ buildSettings: BuildSettings?) throws -> Product? {
        guard let buildSettings = buildSettings,
              let productName = buildSettings["PRODUCT_NAME"] as? String,
              let productType = productType else { return nil }
        let configurationBuildDir = buildSettings["CONFIGURATION_BUILD_DIR"] as? String
        let parentName = configurationBuildDir?.components(separatedBy: "/").last
        return Product(name: productName, type: productType, parentFolderName: parentName)
    }
}
