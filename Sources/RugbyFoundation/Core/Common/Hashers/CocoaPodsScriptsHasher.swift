import Fish

// MARK: - Interface

protocol ICocoaPodsScriptsHasher: AnyObject {
    func hashContext(_ target: IInternalTarget) async throws -> [String]
}

// MARK: - Implementation

final class CocoaPodsScriptsHasher {
    private let fileContentHasher: IFileContentHasher

    init(fileContentHasher: IFileContentHasher) {
        self.fileContentHasher = fileContentHasher
    }
}

extension CocoaPodsScriptsHasher: ICocoaPodsScriptsHasher {
    func hashContext(_ target: IInternalTarget) async throws -> [String] {
        let paths = [target.resourcesScriptPath, target.frameworksScriptPath]
            .compactMap()
            .filter(File.isExist)
        return try await fileContentHasher.hashContext(paths: paths)
    }
}
