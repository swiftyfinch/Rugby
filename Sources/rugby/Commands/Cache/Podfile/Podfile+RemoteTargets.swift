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

        let podsByVersion = try RegEx(pattern: "(?<=- ).*")
            .matches(in: String(specRepos))
            .flatMap { $0.values }
            .compactMap { $0.map(String.init) }

        var podsByGitOptions: [String] = []
        let checkoutOptionsRegex = try RegEx(pattern: #"(?<=CHECKOUT OPTIONS:\n)[\s\S]*?(?=\n\n)"#)
        if let checkoutOptions = checkoutOptionsRegex.firstMatch(in: content)?.values.first ?? nil {
            podsByGitOptions = try RegEx(pattern: #"(?<=  )\b.*\b"#)
                .matches(in: String(checkoutOptions))
                .flatMap { $0.values }
                .compactMap { $0.map(String.init) }
        }

        return (podsByVersion + podsByGitOptions).map { $0.trimmingCharacters(in: ["\""]) }
    }
}
