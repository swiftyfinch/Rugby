import Fish
import Foundation

// MARK: - Interface

/// The protocol describing a manager to clean Rugby folders.
public protocol ICleaner: AnyObject {
    /// Deletes selected shared binaries.
    /// - Parameter names: A collection of binaries to delete.
    func deleteSharedBinaries(names: [String]) async throws

    /// Deletes shared binaries.
    func deleteAllSharedBinaries() async throws

    /// Deletes build folder.
    func deleteBuildFolder() async throws

    /// Deletes tests folder.
    func deleteTestsFolder() async throws
}

// MARK: - Implementation

final class Cleaner {
    private let sharedBinariesPath: String
    private let buildFolderPath: String
    private let testsFolderPath: String

    init(sharedBinariesPath: String,
         buildFolderPath: String,
         testsFolderPath: String) {
        self.sharedBinariesPath = sharedBinariesPath
        self.buildFolderPath = buildFolderPath
        self.testsFolderPath = testsFolderPath
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
    func deleteSharedBinaries(names: [String]) async throws {
        try await names.concurrentForEach { name in
            try await self.deleteFolder(atPath: "\(self.sharedBinariesPath)/\(name)")
        }
    }

    func deleteAllSharedBinaries() async throws {
        try await deleteFolder(atPath: sharedBinariesPath)
    }

    func deleteBuildFolder() async throws {
        try await deleteFolder(atPath: buildFolderPath)
    }

    func deleteTestsFolder() async throws {
        try await deleteFolder(atPath: testsFolderPath)
    }
}
