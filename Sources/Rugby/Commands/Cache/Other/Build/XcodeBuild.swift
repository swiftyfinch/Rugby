//
//  XcodeBuild.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

struct XcodeBuild {
    let project: String
    let scheme: String
    let sdk: SDK
    let arch: String?
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
        arguments.append("| tee " + .buildLog)

        try shell(
            "set -o pipefail && NSUnbufferedIO=YES xcodebuild",
            args: arguments
        )
    }
}
