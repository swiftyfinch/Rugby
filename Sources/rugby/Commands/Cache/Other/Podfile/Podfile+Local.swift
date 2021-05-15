//
//  Podfile+Local.swift
//  
//
//  Created by Vyacheslav Khorkov on 15.05.2021.
//

import RegEx

struct LocalPod {
    let name: String
    let path: String
}

extension Podfile {
    func getLocalPods() throws -> [LocalPod] {
        let content = try read()
        let blockRegex = try RegEx(pattern: #"(?<=EXTERNAL SOURCES:\n)[\s\S]*?(?=\n\n)"#)
        let externalSources = try (blockRegex.firstMatch(in: content)?.values.first)
            .unwrap(orThrow: CacheError.cantParsePodfileLock)

        let matches = try RegEx(pattern: #"\b(.*):\n\s+:path:\s(.*)"#)
            .matches(in: String(externalSources))

        return matches.compactMap { match in
            let values = match.values
                .compactMap { $0 }
                .compactMap(String.init)
            guard values.count == 3 else { return nil }
            return LocalPod(name: values[1], path: values[2].trimmingCharacters(in: ["\""]))
        }
    }
}
