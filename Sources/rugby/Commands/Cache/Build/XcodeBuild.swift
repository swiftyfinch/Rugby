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
    let arch: String

    func build() throws {
        try shellOut(
            to: "set -o pipefail && NSUnbufferedIO=YES xcodebuild",
            arguments: [
                "-project \(project)",
                "-scheme \(scheme)",
                "-sdk iphonesimulator",
                "ARCHS=\(arch)",
                "SYMROOT=$(PWD)/" + .buildFolder,
                "COMPILER_INDEX_STORE_ENABLE=NO",
                "SWIFT_COMPILATION_MODE=wholemodule",
                "| tee " + .buildLog
            ]
        )
    }
}
