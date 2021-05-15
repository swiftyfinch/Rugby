//
//  Podfile+Pods.swift
//  
//
//  Created by Vyacheslav Khorkov on 15.05.2021.
//

import RegEx

extension Podfile {
    func getPods() throws -> Set<String> {
        let content = try read()
        let specReposRegex = try RegEx(pattern: #"(?<=SPEC CHECKSUMS:\n)[\s\S]*?(?=\n\n)"#)
        let specRepos = try (specReposRegex.firstMatch(in: content)?.values.first)
            .unwrap(orThrow: CacheError.cantParseCachedChecksums)

        let pods = try RegEx(pattern: #"(\S+)(?:\:\s\S+)"#)
            .matches(in: String(specRepos))
            .compactMap { $0.values.last }
            .compactMap { $0.map(String.init) }
            .compactMap { $0.trimmingCharacters(in: ["\""]) }

        return Set(pods)
    }
}
