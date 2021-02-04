//
//  XcodeBuild.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Foundation
import ShellOut

struct XcodeBuild {
    let project: String
    let scheme: String

    // todo: Clean up
    func build() throws {
        try shellOut(
            to: "set -o pipefail && NSUnbufferedIO=YES xcodebuild",
            arguments: [
                "-project \(project)",
                "-scheme \(scheme)",
                "-sdk iphonesimulator",
                "ARCHS=x86_64",
                "SYMROOT=$(PWD)/" + .buildFolder,
                "COMPILER_INDEX_STORE_ENABLE=NO",
                "SWIFT_COMPILATION_MODE=wholemodule",
                "SWIFT_OPTIMIZATION_LEVEL=-Onone",
                "| xcbeautify"
                "| tee " + .buildLog
            ],
            errorHandle: FileHandle.standardError
        )
    }
}
