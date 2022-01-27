//
//  XcodeBuild.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct XcodeBuild {
    let project: String
    let scheme: String
    let sdk: SDK
    let arch: String
    let config: String
    let xcargs: [String]

    func build() throws {
        let escapedConfig = config.shellFriendly
        let currentFolder = Folder.current.path.shellFriendly
        var arguments = [
            "-project \(project)",
            "-scheme \(scheme)",
            "-sdk \(sdk.xcodebuild)",
            "-config \(escapedConfig)",
            "ARCHS=\(arch)",
            "SYMROOT=\(currentFolder)\(String.buildFolder)",
            "CONFIGURATION_BUILD_DIR=\(currentFolder)\(String.buildFolder)/\(escapedConfig)-\(sdk.xcodebuild)-\(arch)"
        ]
        arguments.append(contentsOf: xcargs)
        arguments.append("| tee " + .rawBuildLog)

        try XcodeBuildRunner(rawLogPath: .rawBuildLog, logPath: .buildLog).run(
            "NSUnbufferedIO=YES xcodebuild",
            args: arguments
        )
    }
}
