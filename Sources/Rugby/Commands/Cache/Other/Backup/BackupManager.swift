//
//  BackupManager.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 16.06.2022.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

struct BackupManager {
    enum Error: LocalizedError {
        case missingBackup

        var errorDescription: String? {
            switch self {
            case .missingBackup:
                return "Can't find backup."
            }
        }
    }

    private let progress: Printer

    init(progress: Printer) {
        self.progress = progress
    }
}

// MARK: - Backup

extension BackupManager {
    func backup(path: String) throws {
        let project = try ProjectProvider.shared.readProject(path)
        guard !project.pbxproj.main.contains(buildSettingsKey: .rugbyPatched) else {
            return /* Backup already must be */
        }

        let backupFolder = try Folder.current.createSubfolderIfNeeded(at: .backupFolder)
        let filesForBackup = try prepareForBackup(path: path, backupFolder: backupFolder)
        try filesForBackup.forEach { filePath in
            try moveFolder(from: filePath, toBackup: backupFolder)
            progress.print("Backup ".yellow + filePath)
        }
    }

    private func prepareForBackup(path: String, backupFolder: Folder) throws -> [String] {
        if path == .podsProject {
            try deleteLastBackup(relativePath: .podsFolder, backupFolder: backupFolder)
            return [.podsProject, .podsTargetSupportFiles]
        } else {
            try deleteLastBackup(relativePath: path, backupFolder: backupFolder)
            return [path]
        }
    }

    private func deleteLastBackup(relativePath: String, backupFolder: Folder) throws {
        guard let rootSubfolderName = relativePath.components(separatedBy: "/").first else { return }
        backupFolder.deleteSubfolderIfExists(at: rootSubfolderName)
    }

    private func moveFolder(from path: String, toBackup backupFolder: Folder) throws {
        guard let rootSubfolderName = path.components(separatedBy: "/").first else { return }
        let targetFolder = try backupFolder.createSubfolderIfNeeded(at: rootSubfolderName)
        try Folder.current.subfolder(at: path).copy(to: targetFolder)
    }
}

// MARK: - Rollback

extension BackupManager {
    func rollback() throws {
        let map = try prepareRollback()
        try map.forEach { backupFile, targetFolder in
            targetFolder.deleteFileIfExists(at: backupFile.name)
            try backupFile.copy(to: targetFolder)

            let backupFolder = try Folder.current.subfolder(at: .backupFolder)
            let backupPath = backupFile.path(relativeTo: backupFolder)
            let targetFolderPath = targetFolder.path(relativeTo: Folder.current)
            progress.print("Restore ".yellow + backupPath + " ➞ ".yellow + targetFolderPath)
        }
    }

    private func prepareRollback() throws -> [(backupFile: File, targetFolder: Folder)] {
        guard
            let backupFolder = try? Folder.current.subfolder(at: .backupFolder),
            !backupFolder.isEmpty()
        else {
            throw Error.missingBackup
        }

        return backupFolder.files.recursive.compactMap {
            guard let parent = $0.parent else { return nil }
            let parentRelativePath = parent.path(relativeTo: backupFolder)
            guard let targetFolder = try? Folder.current.subfolder(at: parentRelativePath) else { return nil }
            return ($0, targetFolder)
        }
    }
}
