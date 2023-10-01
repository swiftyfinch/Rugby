import Fish

final class CocoaPodsScriptsHasher {
    private let fileContentHasher: FileContentHasher

    init(fileContentHasher: FileContentHasher) {
        self.fileContentHasher = fileContentHasher
    }

    func hashContext(_ target: Target) async throws -> [String] {
        let paths = [target.resourcesScriptPath, target.frameworksScriptPath]
            .compactMap()
            .filter(File.isExist)
        return try await fileContentHasher.hashContext(paths: paths)
    }
}
