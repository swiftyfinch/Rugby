//
//  Utils.swift
//  
//
//  Created by mlch911 on 2023/3/16.
//

import Foundation
import Files

extension String {
    static let buildFrameworkFolder = "XCFrameworkIntermediates"
}

extension BuildCache {
    func LocalCacheFolderName() -> String {
        var nameItems: [String?] = [cacheKeyName(), sdk.rawValue, arch, config, swift]
        nameItems += (xcargs ?? [])
        return nameItems.compactMap { $0 }.joined(separator: "-")
    }
}

extension Pod {
    func contentChecksum(useContentChecksums: Bool) throws -> Checksum {
        if let pod = self as? LocalPod {
            return try pod.combinedChecksum(useContentChecksums: useContentChecksums)
        }
        return checksum
    }
}

extension Folder {
    func copyAllContent(to folder: Folder, override: Bool = false) throws {
        try files.forEach {
            if folder.containsFile(named: $0.name) {
                if override {
                    try folder.file(named: $0.name).delete()
                } else {
                    return
                }
            }
            try $0.copy(to: folder)
        }
        try subfolders.forEach {
            if folder.containsSubfolder(named: $0.name) {
                if override {
                    try folder.subfolder(named: $0.name).delete()
                } else {
                    return
                }
            }
            try $0.copy(to: folder)
        }
    }
    
    func deleteAllContent() throws {
        try files.forEach { try $0.delete() }
        try subfolders.forEach { try $0.delete() }
    }
    
    func contentChecksum() throws -> String {
        try folderContentChecksum(url)
    }
}

func folderContentChecksum(_ url: URL, deep: Bool = true) throws -> String {
    calculateChecksum(try folderContentChecksums(url, deep: deep))
}

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
    for case let url as URL in enumerator {
        let resolvedSymlinksUrl = url.resolvingSymlinksInPath()
        guard FileManager.default.isReadableFile(atPath: resolvedSymlinksUrl.path),
              !resolvedSymlinksUrl.hasDirectoryPath else { continue }
        let data = try Data(contentsOf: url)
        checksums.append(data.sha1())
    }
    return checksums
}

private func calculateChecksum(_ values: [String]) -> String {
    values.joined(separator: "|").sha1()
}
