//
//  CacheManager.swift
//  
//
//  Created by Vyacheslav Khorkov on 29.03.2021.
//

import Files
import Yams

struct SDKCache: Codable {
    let arch: String?
    let swift: String?
    let xcargs: [String]?
    let checksums: [String]?
}

typealias CacheFile = [SDK: SDKCache]

struct CacheManager {
    func load() -> CacheFile? {
        guard let cacheFileData = try? File(path: .cacheFile).read() else { return nil }
        let decoder = YAMLDecoder()
        // Format was changed, so parsing can fail
        let cacheFile = try? decoder.decode(CacheFile.self, from: cacheFileData)
        return cacheFile
    }

    func update(sdk: SDK, _ cache: SDKCache) throws {
        // Update only selected sdk cache
        var cacheFile = load() ?? [:]
        cacheFile[sdk] = cache

        // Save
        let file = try Folder.current.createFileIfNeeded(at: .cacheFile)
        let encoder = YAMLEncoder()
        let cacheFileData = try encoder.encode(cacheFile)
        try file.write(cacheFileData)
    }
}

// MARK: - Checksums

extension CacheManager {
    func checksumsSet(sdk: SDK) -> Set<Checksum> {
        guard let loaded = load()?[sdk] else { return [] }
        let checksums = (loaded.checksums ?? []).compactMap(Checksum.init(string:))
        return Set(checksums)
    }
}
