//
//  SwiftVersionProvider.swift
//  
//
//  Created by Vyacheslav Khorkov on 04.05.2021.
//

struct SwiftVersionProvider {
    func swiftVersion() -> String? {
        guard
            let commandOutput = try? shell("swift --version"),
            let versionRegEx = try? regex(#"(?<=Apple Swift version )(\d+\.\d+)"#),
            let version = try? commandOutput.groups(versionRegEx).first
        else { return nil }
        return String(version)
    }
}
