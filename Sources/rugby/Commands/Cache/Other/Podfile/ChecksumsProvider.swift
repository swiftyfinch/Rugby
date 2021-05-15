//
//  ChecksumsProvider.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import RegEx

struct Checksum: Hashable {
    static let separator = ": "
    let name: String
    var checksum: String

    var string: String { name + Self.separator + checksum }

    init?(string: String) {
        let parts = string.components(separatedBy: Self.separator)
        guard parts.count == 2 else { return nil }
        self.name = parts[0].trimmingCharacters(in: ["\""])
        self.checksum = parts[1]
    }
}

struct ChecksumsProvider {
    let podfile: Podfile

    func getChecksums(forPods pods: Set<String>) throws -> [Checksum] {
        let allChecksums = try podfile.getChecksums()
        let selectedChecksums = allChecksums.filter { pods.contains($0.name) }

        let localPods = try podfile.getLocalPods()
        let localPodsMap = Dictionary(grouping: localPods, by: \.name)
            .compactMapValues(\.first)

        return selectedChecksums.map { podChecksum in
            var podChecksum = podChecksum
            if let localPod = localPodsMap[podChecksum.name], let folderChecksum = localPod.folderChecksum() {
                // Replace checksum for local pods
                // Use native checksum + folder checksum
                podChecksum.checksum = (folderChecksum + podChecksum.checksum).sha1()
            }
            return podChecksum
        }
    }
}

private extension Podfile {
    func getChecksums() throws -> [Checksum] {
        let content = try read()
        let specReposRegex = try RegEx(pattern: #"(?<=SPEC CHECKSUMS:\n)[\s\S]*?(?=\n\n)"#)
        let specRepos = try (specReposRegex.firstMatch(in: content)?.values.first)
            .unwrap(orThrow: CacheError.cantParseCachedChecksums)

        let matches = try RegEx(pattern: #"\S+: \S+"#)
            .matches(in: String(specRepos))

        return matches.compactMap { match in
            let values = match.values
                .compactMap { $0 }
                .compactMap(String.init)
            guard values.count == 1 else { return nil }
            return Checksum(string: values[0])
        }
    }
}
