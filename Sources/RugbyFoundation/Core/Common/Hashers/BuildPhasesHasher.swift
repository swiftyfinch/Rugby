import Fish
import Foundation
import typealias XcodeProj.BuildSettings

// MARK: - Interface

protocol IBuildPhaseHasher: AnyObject {
    func hashContext(target: IInternalTarget) async throws -> Any
}

// MARK: - Implementation

final class BuildPhaseHasher: Loggable {
    let logger: ILogger
    private let workingDirectoryPath: String
    private let fileContentHasher: IFileContentHasher
    private let envVariablesResolver: IEnvVariablesResolver

    private let dollarSymbol = "$"

    init(logger: ILogger,
         workingDirectoryPath: String,
         fileContentHasher: IFileContentHasher,
         envVariablesResolver: IEnvVariablesResolver) {
        self.workingDirectoryPath = workingDirectoryPath
        self.logger = logger
        self.fileContentHasher = fileContentHasher
        self.envVariablesResolver = envVariablesResolver
    }

    // MARK: - Private

    private func hashContext(_ buildPhase: BuildPhase,
                             additionalEnv: [String: String]) async throws -> [String: Any] {
        let inputFileListPaths = try await resolveFileListPaths(buildPhase.inputFileListPaths,
                                                                additionalEnv: additionalEnv)
        var hashContext: [String: Any] = try await [
            "name": buildPhase.name,
            "type": buildPhase.type.rawValue,
            "buildActionMask": buildPhase.buildActionMask,
            "runOnlyForDeploymentPostprocessing": buildPhase.runOnlyForDeploymentPostprocessing,
            "inputFileListPaths": fileContentHasher.hashContext(paths: inputFileListPaths.resolved),
            "outputFileListPaths": preparePaths(buildPhase.outputFileListPaths),
            "files": fileContentHasher.hashContext(paths: buildPhase.files)
        ]
        if inputFileListPaths.unresolved.isNotEmpty {
            hashContext["inputFileListPaths_missing"] = preparePaths(inputFileListPaths.unresolved)
            await log(
                "inputFileListPaths_missing:\n\(preparePaths(inputFileListPaths.unresolved).joined(separator: "\n"))\n",
                output: .file
            )
        }
        return hashContext
    }

    private func preparePaths(_ paths: [String]) -> [String] {
        paths.compactMap { path in
            path.relativePath(to: workingDirectoryPath)
        }.sorted()
    }

    private func resolveFileListPaths(
        _ paths: [String],
        additionalEnv: [String: String]
    ) async throws -> (resolved: [String], unresolved: [String]) {
        let pathsToFileLists = try await paths.concurrentMap {
            try await self.envVariablesResolver.resolve($0, additionalEnv: additionalEnv)
        }

        let (unresolvedFileLists, resolvedFileLists) = Set(pathsToFileLists).partition { $0.contains(dollarSymbol) }
        let resolvedPaths = try await resolvedFileLists.lazy
            .concurrentFlatMap { path in
                let content = try File.read(at: path)
                let pathsFromFile = content.components(separatedBy: "\n")
                return try await pathsFromFile.concurrentMap {
                    try await self.envVariablesResolver.resolve($0, additionalEnv: additionalEnv)
                }
            }

        var resolved: Set<String> = []
        var unresolved = Set(unresolvedFileLists)
        for path in resolvedPaths {
            if path.contains(dollarSymbol) {
                unresolved.insert(path)
            } else if File.isExist(at: path) {
                resolved.insert(path)
            } else {
                unresolved.insert(path)
            }
        }

        return (Array(resolved), Array(unresolved))
    }
}

extension BuildPhaseHasher: IBuildPhaseHasher {
    func hashContext(target: IInternalTarget) async throws -> Any {
        // Get the first configuration sorted by name.
        guard
            let configurationName = (target.configurations ?? [:]).keys.sorted().first,
            let configuration = target.configurations?[configurationName]
        else { return [] }

        // Using sim arch by default. It should be enough.
        let buildSettings = configuration.buildSettings
            .merging(["EFFECTIVE_PLATFORM_NAME": "-\(SDK.sim.xcodebuild)"],
                     uniquingKeysWith: { _, rhs in rhs })

        // Convert the build setting to different format
        var additionalEnv: [String: String] = [:]
        buildSettings.forEach { key, value in
            guard let value = value as? String else { return }
            additionalEnv[key] = value
        }

        return try await target.buildPhases.concurrentMap {
            try await self.hashContext($0, additionalEnv: additionalEnv)
        }
    }
}
