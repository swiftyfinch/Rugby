//
//  BuildRule.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 03.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

struct BuildRule {
    let name: String?
    let compilerSpec: String
    let filePatterns: String?
    let fileType: String
    let isEditable: Bool
    let outputFiles: [String]
    let inputFiles: [String]?
    let outputFilesCompilerFlags: [String]?
    let script: String?
    let runOncePerArchitecture: Bool?
}

extension BuildRule {
    init(_ buildRule: PBXBuildRule) {
        self.name = buildRule.name
        self.compilerSpec = buildRule.compilerSpec
        self.filePatterns = buildRule.filePatterns
        self.fileType = buildRule.fileType
        self.isEditable = buildRule.isEditable
        self.outputFiles = buildRule.outputFiles
        self.inputFiles = buildRule.inputFiles
        self.outputFilesCompilerFlags = buildRule.outputFilesCompilerFlags
        self.script = buildRule.script
        self.runOncePerArchitecture = buildRule.runOncePerArchitecture
    }
}
