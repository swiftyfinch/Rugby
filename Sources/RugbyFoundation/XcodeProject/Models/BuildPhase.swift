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
        guard let name = pbxPhase.name(),
              let type = Kind(pbxPhase.buildPhase) else { return nil }

        self.name = name
        self.type = type
        buildActionMask = pbxPhase.buildActionMask
        runOnlyForDeploymentPostprocessing = pbxPhase.runOnlyForDeploymentPostprocessing
        inputFileListPaths = pbxPhase.inputFileListPaths ?? []
        outputFileListPaths = pbxPhase.outputFileListPaths ?? []
        files = pbxPhase.filePaths()
    }
}

private extension PBXBuildPhase {
    func filePaths() -> [String] {
        guard let files else { return [] }
        return files.compactMap {
            guard let displayName = $0.file?.displayName,
                  let fullPath = $0.file?.fullPath else { return nil }
            // Skipping files with a broken reference.
            // If the reference is broken, the name is non-relative to a full path.
            return fullPath.hasSuffix(displayName) ? fullPath : nil
        }
    }
}

private extension BuildPhase.Kind {
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
