//
//  ChecksumsProvider.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

struct Checksum {
    static let separator = ": "
    let name: String
    var value: String

    var string: String { name + Self.separator + value }

    init?(string: String) {
        let parts = string.components(separatedBy: Self.separator)
        guard parts.count == 2 else { return nil }
        self.name = parts[0].trimmingCharacters(in: ["\""])
        self.value = parts[1]
    }

    init(name: String, checksum: String) {
        self.name = name
        self.value = checksum
    }
}

final class ChecksumsProvider {
    static let shared = ChecksumsProvider()

    private let podsProvider = PodsProvider.shared
    private var cachedChecksums: [String: Checksum]?

    func getChecksums(forPods pods: Set<String>) throws -> [Checksum] {
        let selectedCachedChecksums = pods.compactMap { cachedChecksums?[$0] }
        if selectedCachedChecksums.count == pods.count { return selectedCachedChecksums }

        var checksums: [Checksum] = []
        try podsProvider.remotePods()
            .filter { pods.contains($0.name) }
            .map { try $0.combinedChecksum() }
            .forEach { checksums.append($0) }
        try podsProvider.localPods()
            .filter { pods.contains($0.name) }
            .map { try $0.combinedChecksum() }
            .forEach { checksums.append($0) }
        cachedChecksums = checksums.reduce(into: [:]) { $0[$1.name] = $1 }
        return checksums
    }
}
