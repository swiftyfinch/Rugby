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
    func combinedChecksum(useContentChecksums: Bool) throws -> Checksum
}

extension RemotePod: CombinedChecksum {
    func combinedChecksum(useContentChecksums: Bool) throws -> Checksum {
        let combined = options
            .map { $0.key + ":" + $0.value }
            .sorted()
            .reduce(checksum.value) { calculateChecksum($0, $1) }
        return Checksum(name: name, checksum: combined)
    }
}

extension LocalPod: CombinedChecksum {
    func combinedChecksum(useContentChecksums: Bool) throws -> Checksum {
        let rootFolder = try folder()
        if useContentChecksums {
            // Experimental method that checksums local pod content.
            // This is slower because more work needs to be done to checksum the actual file content.
            // The benefit of this is a more transferable cache. For example in a continuous integration setup
            // every time a new git clone happens all the directories have timestamps of the clone date.
            // This prevents focus from being as effective as it could in these environments
            let checksums = try folderContentChecksums(rootFolder.url, deep: true)
            return Checksum(name: name, checksum: calculateChecksum(checksums))
        } else {
            // Original method that checksums the modification dates for all files in a local pod
            let subfolders = rootFolder.subfolders.filter { !$0.name.contains("Test") }

            let subfoldersModificationDates = try subfolders.flatMap { try folderModificationDates($0.url, deep: true) }
            let rootFilesModificationDates = try folderModificationDates(rootFolder.url, deep: false)

            let checksums = [checksum.value] + subfoldersModificationDates + rootFilesModificationDates
            return Checksum(name: name, checksum: calculateChecksum(checksums))
        }
    }

    private func folder() throws -> Folder {
        let subpath: String
        switch path {
        case ".":
            subpath = name
        case let filePath where !filePath.isDirectory:
            subpath = filePath.dropFileName()
        default:
            subpath = path
        }
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

    /// Collect content checksums from all files in folder. Use `deep` for recursively search.
    private func folderContentChecksums(_ url: URL, deep: Bool) throws -> [String] {
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: nil,
            options: deep ? [.skipsHiddenFiles] : [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { throw CombinedChecksumError.cantBuildFilesEnumerator }

        // PERF: Would likely benefit from parallelization (maybe not, disk bound)
        // Also could benefit from using `CC_SHA1_Init`, `CC_SHA1_Update`, and `CC_SHA1_Final` instead of parsing each
        // checksum into a string.
        // The profile is spending more time in string manipulation than actually checksumming.
        // METRICS: M1 pro (single threaded)
        // 45% loading files
        // 20% string operations
        // 18% directory enumeration
        // 12% SHA1 checksum
        // 5% Other
        var checksums: [String] = []
        for case let url as URL in enumerator where !url.hasDirectoryPath {
            let data = try Data(contentsOf: url)
            checksums.append(data.sha1())
        }
        return checksums
    }
}

// MARK: - Calculate checksum from sequence

private func calculateChecksum(_ values: [String]) -> String {
    values.joined(separator: "|").sha1()
}

private func calculateChecksum(_ values: String...) -> String {
    calculateChecksum(values)
}
