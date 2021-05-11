//
//  CacheManager.swift
//  
//
//  Created by Vyacheslav Khorkov on 29.03.2021.
//

import Files
import Yams

struct CacheFile: Codable {
    let checksums: [String]
    let sdk: SDK?
    let arch: String?
    let swift: String?
    let xcargs: [String]?
}

extension CacheFile {
    static let empty = CacheFile(checksums: [], sdk: nil, arch: nil, swift: nil, xcargs: nil)
}

struct CacheManager {
    func load() throws -> CacheFile {
        if let oldStyleChecksums = try? Podfile(.cachedChecksums).getChecksums() {
            return CacheFile(checksums: oldStyleChecksums, sdk: nil, arch: nil, swift: nil, xcargs: nil)
        }

        guard let cacheFileData = try? File(path: .cacheFile).read() else { return CacheFile.empty }
        let decoder = YAMLDecoder()
        let cacheFile = try decoder.decode(CacheFile.self, from: cacheFileData)
        return cacheFile
    }

    func save(_ cacheFile: CacheFile) throws {
        try? File(path: .cachedChecksums).delete()

        let file = try Folder.current.createFileIfNeeded(at: .cacheFile)
        let encoder = YAMLEncoder()
        let cacheFileData = try encoder.encode(cacheFile)
        try file.write(cacheFileData)
    }
}
