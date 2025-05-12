import Fish
import Foundation
import XcodeProj

// MARK: - Interface

/// The protocol describing a backup manager to save or restore an Xcode project state.
public protocol IBackupManager: AnyObject {
    /// Backups Xcode project.
    /// - Parameters:
    ///   - xcodeProject: A service for Xcode project managment.
    ///   - kind: The type of backup.
    func backup(_ xcodeProject: IXcodeProject, kind: BackupKind) async throws

    /// Restores Xcode project.
    /// - Parameter kind: The type of backup.
    func asyncRestore(_ kind: BackupKind) async throws

    /// Restores Xcode project.
    /// - Parameter kind: The type of backup.
    func restore(_ kind: BackupKind) throws
}

/// The type of backup.
public enum BackupKind: String {
    /// The original state of project before any changes.
    case original
    /// The type to backup intermediate states.
    case tmp
}

enum BackupManagerError: LocalizedError {
    case missingBackup

    var errorDescription: String? {
        let output: String
        switch self {
        case .missingBackup:
            output = "Can't find backup."
        }
        return output
    }
}

// MARK: - Implementation

final class BackupManager {
    private typealias Error = BackupManagerError

    private let backupFolderPath: String
    private let workingDirectory: IFolder
    private let hasBackupKey: String

    private let yes: BuildSetting = true
    private let targetSupportFiles = "Target Support Files"

    init(backupFolderPath: String,
         workingDirectory: IFolder,
         hasBackupKey: String) {
        self.backupFolderPath = backupFolderPath
        self.workingDirectory = workingDirectory
        self.hasBackupKey = hasBackupKey
    }
}

private extension BackupKind {
    var folderName: String { rawValue }
}

// MARK: - Private Backup

extension BackupManager {
    private func backupFolderPath(subfolderName: String) -> String {
        "\(backupFolderPath)/\(subfolderName)"
    }

    private func backup(_ projects: [IFolder], to folderName: String) async throws {
        let backupFolderPath = backupFolderPath(subfolderName: folderName)
        let steps = try backupSteps(for: projects, to: backupFolderPath)
        projects.forEach { project in
            let path = "\(backupFolderPath)/\(project.nameExcludingExtension)"
            try? Folder.delete(at: path)
        }
        try await applySteps(steps)
    }

    private func backupSteps(for projectFolders: [IFolder],
                             to backupFolderPath: String) throws -> [(source: IFile, target: String)] {
        var folders = projectFolders
        let targetSupportFilesPath = projectFolders.first?.parent?.subpath(targetSupportFiles)
        if let path = targetSupportFilesPath, let folder = try? Folder.at(path) {
            folders.append(folder)
        }
        return try folders.lazy
            .flatMap { folder in
                try folder.files(deep: true)
            }
            .compactMap { file in
                guard let destinationFolder = file.parent?.relativePath(to: workingDirectory),
                      let projectFolderName = destinationFolder.components(separatedBy: "/").first else { return nil }
                let projectName = projectFolderName.excludingExtension()
                let target = "\(backupFolderPath)/\(projectName)/\(destinationFolder)"
                return (source: file, target: target)
            }
    }
}

// MARK: - Private Restore

extension BackupManager {
    private func restoreSteps(from subfolderName: String) throws -> [(source: IFile, target: String)] {
        let backupFolderPath = backupFolderPath(subfolderName: subfolderName)
        guard let backupFolder = try? Folder.at(backupFolderPath),
              try !backupFolder.isEmpty() else { throw Error.missingBackup }

        return try restoreSteps(from: backupFolder)
    }

    private func restoreSteps(from backupFolder: IFolder) throws -> [(source: IFile, target: String)] {
        let subfolders = try backupFolder.folders()
        return try subfolders.flatMap { folder -> [(source: IFile, target: String)] in
            let files = try folder.files(deep: true)
            return files.compactMap { file in
                guard let destinationFolderSubpath = file.parent?.relativePath(to: folder) else { return nil }
                return (file, workingDirectory.subpath(destinationFolderSubpath))
            }
        }
    }
}

// MARK: - Common Steps

extension BackupManager {
    private func applySteps(_ steps: [(source: IFile, target: String)]) async throws {
        try await steps.concurrentForEach { file, folderPath in
            try file.copy(to: folderPath, replace: true)
        }
    }

    private func applySteps(_ steps: [(source: IFile, target: String)]) throws {
        try steps.forEach { file, folderPath in
            try file.copy(to: folderPath, replace: true)
        }
    }
}

// MARK: - IBackupManager

extension BackupManager: IBackupManager {
    public func backup(_ xcodeProject: IXcodeProject, kind: BackupKind) async throws {
        let projects = try await xcodeProject.folderPaths().map(Folder.at)
        switch kind {
        case .original:
            guard try await !xcodeProject.contains(buildSettingsKey: hasBackupKey) else {
                return
            }
            try await backup(projects, to: kind.folderName)
            try await xcodeProject.set(buildSettingsKey: hasBackupKey, value: yes)
        case .tmp:
            try await backup(projects, to: kind.folderName)
        }
    }

    public func asyncRestore(_ kind: BackupKind) async throws {
        let steps = try restoreSteps(from: kind.folderName)
        try await applySteps(steps)
    }

    public func restore(_ kind: BackupKind) throws {
        let steps = try restoreSteps(from: kind.folderName)
        try applySteps(steps)
    }
}
