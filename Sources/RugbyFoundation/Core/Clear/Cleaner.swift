import Fish
import Foundation

// MARK: - Interface

/// The protocol describing a manager to clean Rugby folders.
public protocol ICleaner {
    /// Deletes selected shared binaries.
    /// - Parameter names: A collection of binaries to delete.
    func deleteSharedBinaries(names: [String]) async throws

    /// Deletes shared binaries.
    func deleteAllSharedBinaries() async throws

    /// Deletes build folder.
    func deleteBuildFolder() async throws
}

// MARK: - Implementation

final class Cleaner {
    private let sharedBinariesPath: String
    private let buildFolderPath: String

    init(sharedBinariesPath: String,
         buildFolderPath: String) {
        self.sharedBinariesPath = sharedBinariesPath
        self.buildFolderPath = buildFolderPath
    }

    private func deleteFolder(atPath path: String) async throws {
        guard Folder.isExist(at: path) else { return }

        let folder = try Folder.at(path)
        try await folder.files(deep: true).concurrentForEach { file in
            try file.delete()
        }
        try folder.delete()
    }
}

// MARK: - IСleaner

extension Cleaner: ICleaner {
    public func deleteSharedBinaries(names: [String]) async throws {
        try await names.concurrentForEach { name in
            try await self.deleteFolder(atPath: "\(self.sharedBinariesPath)/\(name)")
        }
    }

    public func deleteAllSharedBinaries() async throws {
        try await deleteFolder(atPath: sharedBinariesPath)
    }

    public func deleteBuildFolder() async throws {
        try await deleteFolder(atPath: buildFolderPath)
    }
}
