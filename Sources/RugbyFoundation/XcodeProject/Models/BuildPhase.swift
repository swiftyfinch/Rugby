import enum XcodeProj.BuildPhase
import class XcodeProj.PBXBuildFile
import class XcodeProj.PBXBuildPhase
import class XcodeProj.PBXVariantGroup

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

    init(
        name: String,
        type: Kind,
        buildActionMask: UInt = PBXBuildPhase.defaultBuildActionMask,
        runOnlyForDeploymentPostprocessing: Bool = false,
        inputFileListPaths: [String] = [],
        outputFileListPaths: [String] = [],
        files: [String] = []
    ) {
        self.name = name
        self.type = type
        self.buildActionMask = buildActionMask
        self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
        self.inputFileListPaths = inputFileListPaths
        self.outputFileListPaths = outputFileListPaths
        self.files = files
    }
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
        (files ?? []).flatMap { buildFile -> [String] in
            guard let fullPath = buildFile.file?.fullPath else { return [] }

            if let variantGroup = buildFile.file as? PBXVariantGroup, let path = variantGroup.path {
                // Returning children in group instead of a path to directory
                return variantGroup.children.compactMap {
                    guard let childPath = $0.path else { return nil }
                    return "\(fullPath)/\(path)/\(childPath)"
                }
            }

            guard let displayName = buildFile.file?.displayName else { return [] }

            // Skipping files with a broken reference.
            // If the reference is broken, the name is non-relative to a full path.
            return fullPath.hasSuffix(displayName) ? [fullPath] : []
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
