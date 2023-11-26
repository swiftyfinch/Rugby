import Fish
import Foundation

// MARK: - Interface

protocol IFileContentHasher: AnyObject {
    func hashContext(paths: [String]) async throws -> [String]
}

// MARK: - Implementation

final class FileContentHasher {
    private let foundationHasher: FoundationHasher
    private let workingDirectory: IFolder

    init(foundationHasher: FoundationHasher, workingDirectory: IFolder) {
        self.foundationHasher = foundationHasher
        self.workingDirectory = workingDirectory
    }

    // MARK: - Private

    private func hashContext(path: String) throws -> String {
        let file = try File.at(path)
        return try "\(relativePath(of: file)): \(hash(file))"
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

    // Traversing from working directory to its parents to find nearest common parent.
    private func relativePath(of file: IFile) -> String {
        var relativePath = file.path
        var current: IFolder? = workingDirectory
        while relativePath == file.path, let toFolder = current {
            relativePath = file.relativePath(to: toFolder)
            current = toFolder.parent
        }
        return relativePath
    }
}

extension FileContentHasher: IFileContentHasher {
    func hashContext(paths: [String]) async throws -> [String] {
        try await flatPaths(paths).sorted().concurrentMap(hashContext)
    }
}
