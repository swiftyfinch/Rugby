import Fish
import Foundation

// MARK: - Interface

protocol ITestsStorage {
    func saveTests(
        of targets: TargetsMap,
        buildOptions: XcodeBuildOptions
    ) async throws

    func findMissingTests(
        of targets: TargetsMap,
        buildOptions: XcodeBuildOptions
    ) async throws -> [IInternalTarget]
}

// MARK: - Implementation

final class TestsStorage: Loggable {
    let logger: ILogger
    private let binariesStorage: IBinariesStorage
    private let sharedPath: String

    init(logger: ILogger,
         binariesStorage: IBinariesStorage,
         sharedPath: String) {
        self.logger = logger
        self.binariesStorage = binariesStorage
        self.sharedPath = sharedPath
    }

    // MARK: - Methods

    private func findTestsCachePaths(
        for targets: TargetsMap,
        buildOptions: XcodeBuildOptions
    ) async throws -> [(target: IInternalTarget, fullPath: URL, hashContext: String)] {
        try await targets.values.concurrentCompactMap { target in
            guard let hash = target.hash, let hashContext = target.hashContext else { return nil }
            let relativePath = try self.binariesStorage.binaryRelativePath(target, buildOptions: buildOptions)
            let fullPath = URL(fileURLWithPath: "\(self.sharedPath)/\(relativePath)/\(hash).yml")
            return (target, fullPath, hashContext)
        }
    }
}

extension TestsStorage: ITestsStorage {
    func saveTests(
        of targets: TargetsMap,
        buildOptions: XcodeBuildOptions
    ) async throws {
        try await findTestsCachePaths(for: targets, buildOptions: buildOptions)
            .concurrentForEach { _, fullPath, hashContext in
                try Folder.create(at: fullPath.deletingLastPathComponent().path)
                try File.create(at: fullPath.path, contents: hashContext)
                await self.logPlain(fullPath.path, output: .file)
            }
    }

    func findMissingTests(
        of targets: TargetsMap,
        buildOptions: XcodeBuildOptions
    ) async throws -> [IInternalTarget] {
        try await log("Finding Tests in Cache", block: {
            try await findTestsCachePaths(for: targets, buildOptions: buildOptions)
                .concurrentCompactMap { target, fullPath, _ in
                    let isFileExist = File.isExist(at: fullPath.path)
                    await self.logPlain("\(isFileExist ? "+" : "-") \(fullPath)", output: .file)
                    return isFileExist ? nil : target
                }
        })
    }
}
