//
//  Podfile+RemoteTargets.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import RegEx

extension Podfile {
    func getRemotePods() throws -> [String] {
        let content = try read()
        let specReposRegex = try RegEx(pattern: #"(?<=SPEC REPOS:\n)[\s\S]*?(?=\n\n)"#)
        let specRepos = try (specReposRegex.firstMatch(in: content)?.values.first)
            .unwrap(orThrow: CacheError.cantParsePodfileLock)

        return try RegEx(pattern: "(?<=- ).*")
            .matches(in: String(specRepos))
            .flatMap { $0.values }
            .compactMap { $0.map(String.init) }
    }
}
