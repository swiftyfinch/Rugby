//
//  Bundle.swift
//  AutoMate
//
//  Created by Bartosz Janda on 28.03.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

extension Bundle {

    /// AutoMate Bundle Identifier
    public static let autoMateIdentifier = "com.pgs-soft.AutoMate"

    /// AutoMate framework bundle
    public class var autoMate: Bundle {
        guard let bundle = Bundle(identifier: autoMateIdentifier) else {
            preconditionFailure("Cannot find allow button.")
        }
        return bundle
    }
}
