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
		let arch: ARCH
        switch self {
        case .ios:
			arch = ARCH.arm64
        case .sim:
			arch = systemArch() ?? .x86_64
        }
		return arch.rawValue
    }
}

import Foundation

private func systemArch() -> ARCH? {
	var systeminfo = utsname()
	uname(&systeminfo)
	let machine = withUnsafeBytes(of: &systeminfo.machine) { bufPtr -> String in
		let data = Data(bufPtr)
		if let lastIndex = data.lastIndex(where: {$0 != 0}) {
			return String(data: data[0...lastIndex], encoding: .isoLatin1)!
		} else {
			return String(data: data, encoding: .isoLatin1)!
		}
	}
	return ARCH(rawValue: machine)
}
