@testable import RugbyFoundation

extension BuildRule {
    static func mock(name: String) -> BuildRule {
        .init(
            name: name,
            compilerSpec: "",
            filePatterns: nil,
            fileType: "",
            isEditable: false,
            outputFiles: [],
            inputFiles: nil,
            outputFilesCompilerFlags: nil,
            script: nil,
            runOncePerArchitecture: nil
        )
    }
}
