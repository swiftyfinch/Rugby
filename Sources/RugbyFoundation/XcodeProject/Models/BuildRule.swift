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
        name = buildRule.name
        compilerSpec = buildRule.compilerSpec
        filePatterns = buildRule.filePatterns
        fileType = buildRule.fileType
        isEditable = buildRule.isEditable
        outputFiles = buildRule.outputFiles
        inputFiles = buildRule.inputFiles
        outputFilesCompilerFlags = buildRule.outputFilesCompilerFlags
        script = buildRule.script
        runOncePerArchitecture = buildRule.runOncePerArchitecture
    }
}
