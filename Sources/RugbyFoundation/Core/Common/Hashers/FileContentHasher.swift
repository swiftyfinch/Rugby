import Fish
import Foundation

final class FileContentHasher {
    private let foundationHasher: FoundationHasher
    private let workingDirectory: IFolder

    init(foundationHasher: FoundationHasher, workingDirectory: IFolder) {
        self.foundationHasher = foundationHasher
        self.workingDirectory = workingDirectory
    }

    func hashContext(paths: [String]) async throws -> [String] {
        try await flatPaths(paths).sorted().concurrentMap(hashContext)
    }

    // MARK: - Private

    private func hashContext(path: String) throws -> String {
        let file = try File.at(path)
        return try "\(file.relativePath(to: workingDirectory)): \(hash(file))"
    }

    private func hash(_ file: IFile) throws -> String {
        try autoreleasepool {
            let data = try file.readData()
            return foundationHasher.hash(data)
        }
    }

    private func flatPaths(_ paths: [String]) throws -> Set<String> {
        try paths.reduce(into: []) { paths, path in
            if isFolder(at: path) {
                let files = try Folder.at(path).files(deep: true)
                paths.formUnion(files.map(\.path))
            } else {
                paths.insert(path)
            }
        }
    }
}
