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
        guard !project.pbxproj.main.contains(buildSettingsKey: .rugbyHasBackup) else {
            return /* Backup already must be */
        }

        let backupFolder = try Folder.current.createSubfolderIfNeeded(at: .backupFolder)
        let filesForBackup = try prepareForBackup(path: path, backupFolder: backupFolder)
        try filesForBackup.forEach { filePath, targetFolder in
            try Folder.current.subfolder(at: filePath).copy(to: targetFolder)
            progress.print("Backup ".yellow + filePath, level: .vv)
        }
        project.pbxproj.main.set(buildSettingsKey: .rugbyHasBackup, value: String.yes)
    }

    private func prepareForBackup(path: String, backupFolder: Folder) throws -> [(String, Folder)] {
        if path == .podsProject {
            backupFolder.deleteSubfolderIfExists(at: .podsFolder)
            let podsFolder = try backupFolder.createSubfolder(at: .podsFolder)
            return [(.podsProject, podsFolder), (.podsTargetSupportFiles, podsFolder)]
        } else {
            guard let rootSubfolderName = path.components(separatedBy: "/").first else { return [] }
            backupFolder.deleteSubfolderIfExists(at: rootSubfolderName)
            return [(rootSubfolderName, backupFolder)]
        }
    }
}

// MARK: - Rollback

extension BackupManager {
    func rollback() throws {
        let filesToRestore = try prepareRollback()
        try filesToRestore.forEach { backupFile, targetFolder in
            targetFolder.deleteFileIfExists(at: backupFile.name)
            try backupFile.copy(to: targetFolder)

            let backupFolder = try Folder.current.subfolder(at: .backupFolder)
            let backupPath = backupFile.path(relativeTo: backupFolder)
            let targetFolderPath = targetFolder.path(relativeTo: Folder.current)
            progress.print("Restore ".yellow + backupPath + " from ".yellow + targetFolderPath, level: .vv)
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
