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
            let versionRegEx = try? #"(?<=Apple Swift version )(\d+\.\d+)"#.regex(),
            let version = try? commandOutput.groups(versionRegEx).first
        else { return nil }
        return String(version)
    }
}
