//
//  SDK.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser

enum SDK: String, Codable, ExpressibleByArgument {
    case sim, ios

    var xcodebuild: String {
        switch self {
        case .sim: return "iphonesimulator"
        case .ios: return "iphoneos"
        }
    }

    var defaultARCH: String {
        switch self {
        case .ios:
            return ARCH.arm64.rawValue
        case .sim:
            return ARCH.x86_64.rawValue
        }
    }
}
