//
//  XcodeBuild.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import ShellOut

struct XcodeBuild {
    let project: String
    let scheme: String
    let sdk: SDK
    let arch: String?

    func build() throws {
        var arguments = [
            "-project \(project)",
            "-scheme \(scheme)",
            "-sdk \(sdk.xcodebuild)",
            "SYMROOT=$(PWD)/" + .buildFolder,
            "COMPILER_INDEX_STORE_ENABLE=NO",
            "SWIFT_COMPILATION_MODE=wholemodule"
        ]

        if sdk == .ios { arguments.append("ENABLE_BITCODE=NO") }
        if let arch = arch {
            arguments.append("ARCHS=\(arch)")
        }
        arguments.append("| tee " + .buildLog)

        try shellOut(
            to: "set -o pipefail && NSUnbufferedIO=YES xcodebuild",
            arguments: arguments
        )
    }
}
