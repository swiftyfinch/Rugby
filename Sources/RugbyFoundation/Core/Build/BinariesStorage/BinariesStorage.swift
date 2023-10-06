import Fish
import Foundation

// MARK: - Interface

protocol IBinariesStorage: AnyObject {
    var sharedPath: String { get }

    func binaryRelativePath(_ target: IInternalTarget, buildOptions: XcodeBuildOptions) throws -> String
    func finderBinaryFolderPath(_ target: IInternalTarget, buildOptions: XcodeBuildOptions) throws -> String
    func xcodeBinaryFolderPath(_ target: IInternalTarget) throws -> String

    func saveBinaries(
        ofTargets targets: TargetsMap,
        buildOptions: XcodeBuildOptions,
        buildPaths: XcodeBuildPaths
    ) async throws

    func findBinaries(
        ofTargets targets: TargetsMap,
        buildOptions: XcodeBuildOptions
    ) throws -> (found: TargetsMap, notFound: TargetsMap)
}

enum BinariesStorageError: LocalizedError {
    case targetHasNotProduct(String)

    var errorDescription: String? {
        switch self {
        case let .targetHasNotProduct(targetName):
            return "Target '\(targetName)' has not product."
        }
    }
}

// MARK: - Implementation

final class BinariesStorage: Loggable {
    private typealias Error = BinariesStorageError

    let logger: ILogger
    let sharedPath: String
    private let keepHashYamls: Bool

    private let xcodeConfigFolder = "${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}"
    private let latestFileName = "+latest"

    init(logger: ILogger,
         sharedPath: String,
         keepHashYamls: Bool) {
        self.logger = logger
        self.sharedPath = sharedPath
        self.keepHashYamls = keepHashYamls
    }

    // MARK: - Private

    private func binaryRelativePath(_ target: IInternalTarget, configFolder: String) throws -> String {
        guard let binaryName = target.product?.name else { throw Error.targetHasNotProduct(target.name) }
        let hashFolder = target.hash.map { "/" + $0 } ?? ""
        return "\(binaryName)/\(configFolder)\(hashFolder)"
    }

    private func binaryFolderPath(_ target: IInternalTarget, configFolder: String) throws -> String {
        let relativePath = try binaryRelativePath(target, configFolder: configFolder)
        return "\(sharedPath)/\(relativePath)"
    }

    private func buildConfigFolder(buildOptions: XcodeBuildOptions, buildPaths: XcodeBuildPaths) -> String {
        "\(buildPaths.symroot)/\(buildOptions.config)-\(buildOptions.sdk.xcodebuild)/"
    }

    private func binariesConfigFolder(buildOptions: XcodeBuildOptions) -> String {
        "\(buildOptions.config)-\(buildOptions.sdk.xcodebuild)-\(buildOptions.arch)"
    }

    private func moveBinariesSteps(
        ofTargets targets: TargetsMap,
        buildConfigFolder: String,
        sharedBinariesConfigFolder: String
    ) async throws -> [(source: [IItem], hashContext: String?, target: String)] {
        try targets.values.reduce(into: []) { result, target in
            guard let product = target.product, let productFolderName = product.parentFolderName else {
                throw Error.targetHasNotProduct(target.name)
            }

            let productFiles: [IItem]
            // Copy bundle to separate bin folder
            if target.product?.type == .bundle {
                let binaryPath = "\(buildConfigFolder)\(product.nameWithParent)"
                productFiles = try [Folder.at(binaryPath)]
            } else {
                let productFolder = try Folder.at("\(buildConfigFolder)\(productFolderName)")
                let foldersExceptBundle = try productFolder.folders().filter {
                    $0.pathExtension != .bundleExtension
                }
                productFiles = try productFolder.files() + foldersExceptBundle
            }

            let targetFolder = try binaryFolderPath(target, configFolder: sharedBinariesConfigFolder)
            result.append((productFiles, target.hashContext, targetFolder))
        }
    }

    private func createLatestFile(paths: [String], in folder: IFolder) throws {
        let content = "\(paths.caseInsensitiveSorted().joined(separator: "\n"))\n"
        try folder.createFile(named: latestFileName, contents: content)
    }

    private func patchModuleMap(_ modulemap: IFile) throws {
        guard let parentPath = modulemap.parent?.path else { return }
        try modulemap.replaceOccurrences(of: "\(parentPath)/")
    }
}

// MARK: - IBinariesStorage

extension BinariesStorage: IBinariesStorage {
    func binaryRelativePath(_ target: IInternalTarget, buildOptions: XcodeBuildOptions) throws -> String {
        let binariesConfigFolder = binariesConfigFolder(buildOptions: buildOptions)
        return try binaryRelativePath(target, configFolder: binariesConfigFolder)
    }

    func finderBinaryFolderPath(_ target: IInternalTarget, buildOptions: XcodeBuildOptions) throws -> String {
        let binariesConfigFolder = binariesConfigFolder(buildOptions: buildOptions)
        return try binaryFolderPath(target, configFolder: binariesConfigFolder)
    }

    func xcodeBinaryFolderPath(_ target: IInternalTarget) throws -> String {
        try binaryFolderPath(target, configFolder: xcodeConfigFolder).homeEnvRelativePath()
    }

    func saveBinaries(
        ofTargets targets: TargetsMap,
        buildOptions: XcodeBuildOptions,
        buildPaths: XcodeBuildPaths
    ) async throws {
        let buildConfigFolder = buildConfigFolder(buildOptions: buildOptions,
                                                  buildPaths: buildPaths)
        let binariesConfigFolder = binariesConfigFolder(buildOptions: buildOptions)
        let steps = try await moveBinariesSteps(ofTargets: targets,
                                                buildConfigFolder: buildConfigFolder,
                                                sharedBinariesConfigFolder: binariesConfigFolder)

        // Log
        let binariesList = steps.map { "+ \($0.target.homeFinderRelativePath())" }
            .caseInsensitiveSorted()
            .joined(separator: "\n")
        await log("Moving Binaries:\n\(binariesList)", level: .info)

        // Moving
        let sharedFolder = try Folder.create(at: sharedPath)
        try createLatestFile(paths: steps.map(\.target), in: sharedFolder)

        try await steps.concurrentForEach { productFiles, hashContext, destinationFolderPath in
            let destinationFolder = try Folder.create(at: destinationFolderPath)
            try productFiles.forEach { file in
                if file.pathExtension == .modulemapExtension {
                    try (file as? IFile).map(self.patchModuleMap)
                }
                try file.move(to: destinationFolderPath, replace: true)
            }

            if self.keepHashYamls, let hashContext {
                let fileName = "\(destinationFolder.name).yml"
                try destinationFolder.createFile(named: fileName, contents: hashContext)
            }
        }

        // Clean up
        let emptyFolders = try Folder.at(buildConfigFolder).folders().filter { folder in
            try folder.isEmpty()
        }
        try emptyFolders.forEach { folder in
            try folder.delete()
        }
    }

    func findBinaries(
        ofTargets targets: TargetsMap,
        buildOptions: XcodeBuildOptions
    ) throws -> (found: TargetsMap, notFound: TargetsMap) {
        let configFolder = binariesConfigFolder(buildOptions: buildOptions)
        return try targets.partition { _, target in
            let path = try binaryFolderPath(target, configFolder: configFolder)
            return Folder.isExist(at: path)
        }
    }
}

private extension String {
    static let bundleExtension = "bundle"
    static let modulemapExtension = "modulemap"
}
