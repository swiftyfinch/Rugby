import Fish

final class CocoaPodsScriptsHasher {
    private let fileContentHasher: IFileContentHasher

    init(fileContentHasher: IFileContentHasher) {
        self.fileContentHasher = fileContentHasher
    }

    func hashContext(_ target: IInternalTarget) async throws -> [String] {
        let paths = [target.resourcesScriptPath, target.frameworksScriptPath]
            .compactMap()
            .filter(File.isExist)
        return try await fileContentHasher.hashContext(paths: paths)
    }
}
