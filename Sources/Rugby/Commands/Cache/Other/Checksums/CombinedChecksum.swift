//
//  CombinedChecksum.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

enum CombinedChecksumError: Error {
    case cantBuildFilesEnumerator
    case cantGetModificationDate
}

protocol CombinedChecksum {
    func combinedChecksum() throws -> Checksum
}

extension RemotePod: CombinedChecksum {
    func combinedChecksum() throws -> Checksum {
        let combined = options
            .map { $0.key + ":" + $0.value }
            .sorted()
            .reduce(checksum.value) { calculateChecksum($0, $1) }
        return Checksum(name: name, checksum: combined)
    }
}

extension LocalPod: CombinedChecksum {
    func combinedChecksum() throws -> Checksum {
        let rootFolder = try folder()
        let subfolders = rootFolder.subfolders.filter { !$0.name.contains("Test") }

        let subfoldersModificationDates = try subfolders.flatMap { try folderModificationDates($0.url, deep: true) }
        let rootFilesModificationDates = try folderModificationDates(rootFolder.url, deep: false)

        let checksums = [checksum.value] + subfoldersModificationDates + rootFilesModificationDates
        return Checksum(name: name, checksum: calculateChecksum(checksums))
    }

    private func folder() throws -> Folder {
        let subpath = path == "." ? name : path
        return try Folder.current.subfolder(at: subpath)
    }

    /// Collect modification dates from all files in folder. Use `deep` for recursively search.
    private func folderModificationDates(_ url: URL, deep: Bool) throws -> [String] {
        typealias Error = CombinedChecksumError
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.attributeModificationDateKey],
            options: deep ? [.skipsHiddenFiles] : [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { throw Error.cantBuildFilesEnumerator }

        var dates: [String] = []
        for case let url as URL in enumerator where !url.hasDirectoryPath {
            let resources = try url.resourceValues(forKeys: [.attributeModificationDateKey])
            guard let date = resources.attributeModificationDate else { throw Error.cantGetModificationDate }
            let string = String(date.timeIntervalSinceReferenceDate)
            dates.append(string)
        }
        return dates
    }
}

// MARK: - Calculate checksum from sequence

private func calculateChecksum(_ values: [String]) -> String {
    values.joined(separator: "|").sha1()
}

private func calculateChecksum(_ values: String...) -> String {
    calculateChecksum(values)
}
