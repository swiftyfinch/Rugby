//
//  SwiftVersionProvider.swift
//  
//
//  Created by Vyacheslav Khorkov on 04.05.2021.
//

import RegEx
import ShellOut

struct SwiftVersionProvider {
    func swiftVersion() -> String? {
        guard
            let commandOutput = try? shellOut(to: "swift --version"),
            let versionRegEx = try? RegEx(pattern: #"(?<=Apple Swift version )(\d+\.\d+)"#),
            let version = versionRegEx.firstMatch(in: commandOutput)?.values.compactMap({ $0 }).first
        else { return nil }
        return String(version)
    }
}
