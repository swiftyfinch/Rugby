import enum XcodeProj.BuildPhase
import class XcodeProj.PBXBuildFile
import class XcodeProj.PBXBuildPhase

struct BuildPhase {
    enum Kind: String {
        case sources
        case frameworks
        case resources
        case copyFiles
        case runScript
        case headers
    }

    let name: String
    let type: Kind
    let buildActionMask: UInt
    let runOnlyForDeploymentPostprocessing: Bool
    let inputFileListPaths: [String]
    let outputFileListPaths: [String]
    let files: [String]
}

// MARK: - Conversions

extension BuildPhase {
    init?(_ pbxPhase: PBXBuildPhase) {
        guard
            let name = pbxPhase.name(),
            let type = Kind(pbxPhase.buildPhase),
            let files = pbxPhase.files?.compactMap(\.file?.fullPath)
        else { return nil }

        self.name = name
        self.type = type
        buildActionMask = pbxPhase.buildActionMask
        runOnlyForDeploymentPostprocessing = pbxPhase.runOnlyForDeploymentPostprocessing
        inputFileListPaths = pbxPhase.inputFileListPaths ?? []
        outputFileListPaths = pbxPhase.outputFileListPaths ?? []
        self.files = files
    }
}

extension BuildPhase.Kind {
    init?(_ phase: XcodeProj.BuildPhase) {
        switch phase {
        case .sources:
            self = .sources
        case .frameworks:
            self = .frameworks
        case .resources:
            self = .resources
        case .copyFiles:
            self = .copyFiles
        case .runScript:
            self = .runScript
        case .headers:
            self = .headers
        case .carbonResources:
            // Legacy Carbon resources are unsupported
            return nil
        }
    }
}
