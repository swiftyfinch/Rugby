//
//  Podfile+Checksum.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import RegEx

extension Podfile {
    func getChecksums() throws -> [String] {
        let content = try read()
        let specReposRegex = try RegEx(pattern: #"(?<=SPEC CHECKSUMS:\n)[\s\S]*?(?=\n\n)"#)
        let specRepos = try (specReposRegex.firstMatch(in: content)?.values.first)
            .unwrap(orThrow: CacheError.cantParseCachedChecksums)

        return try RegEx(pattern: #"\S+: \S+"#)
            .matches(in: String(specRepos))
            .compactMap { $0.values.first }
            .compactMap { $0.map(String.init) }
    }
}
