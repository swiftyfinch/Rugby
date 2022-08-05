//
//  ChecksumsProvider.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
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
    private let podsProvider = PodsProvider.shared
    private static var cachedChecksums: [String: Checksum] = [:]

    private let useContentChecksums: Bool

    init(useContentChecksums: Bool) {
        self.useContentChecksums = useContentChecksums
    }

    func getChecksums(forPods pods: Set<String>) throws -> [Checksum] {
        let checksums = try podsProvider.pods()
            .filter { pods.contains($0.name) }
            .map { try getChecksum(forPod: $0) }

        assert(pods.count == checksums.count, "Asked to checksum unknown pod(s)")
        return checksums
    }

    private func getChecksum(forPod pod: Pod & CombinedChecksum) throws -> Checksum {
        if let cachedChecksum = Self.cachedChecksums[pod.name] {
            return cachedChecksum
        }

        let checksum = try pod.combinedChecksum(useContentChecksums: useContentChecksums)
        Self.cachedChecksums[pod.name] = checksum
        return checksum
    }
}
