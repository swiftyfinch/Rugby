//
//  XcodeBuild.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct XcodeBuild {
    let project: String
    let scheme: String
    let sdk: SDK
    let arch: String?
    let config: String?
    let xcargs: [String]

    func build() throws {
        var arguments = [
            "-project \(project)",
            "-scheme \(scheme)",
            "-sdk \(sdk.xcodebuild)",
            "SYMROOT=$(PWD)/" + .buildFolder
        ]
        arguments.append(contentsOf: xcargs)

        if let arch = arch {
            arguments.append("ARCHS=\(arch)")
        }
        if let config = config {
            arguments.append("-config \(config)")
        }
        arguments.append(" | tee " + .rawBuildLog)

        try XcodeBuildRunner(rawLogPath: .rawBuildLog, logPath: .buildLog).run(
            "set -o pipefail && NSUnbufferedIO=YES xcodebuild",
            args: arguments
        )
    }
}
