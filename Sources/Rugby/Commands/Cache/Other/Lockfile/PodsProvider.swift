//
//  PodsProvider.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

final class PodsProvider {
    static let shared = PodsProvider()

    func localPods() throws -> [LocalPod] {
        try parse().localPods
    }

    func remotePods() throws -> [RemotePod] {
        try parse().remotePods
    }

    func pods() throws -> [Pod & CombinedChecksum] {
        let parsed = try parse()
        return parsed.localPods + parsed.remotePods
    }

    private var cachedLocalPods: [LocalPod]?
    private var cachedRemotePods: [RemotePod]?
}

// MARK: - Parse

extension PodsProvider {
    private func parse() throws -> (localPods: [LocalPod], remotePods: [RemotePod]) {
        if let locaPods = cachedLocalPods, let remotePods = cachedRemotePods {
            return (locaPods, remotePods)
        }

        var localPods: [String: LocalPod] = [:]
        var remotePods: [String: RemotePod] = [:]
        let lockfile = try Lockfile(path: .lockfile)
        for repo in lockfile.specRepos {
            for pod in repo.value {
                guard let checksum = lockfile.specChecksums[pod] else { continue }
                remotePods[pod] = RemotePod(name: pod, repo: repo.key, checksum: checksum)
            }
        }
        for source in lockfile.externalSources {
            guard let checksum = lockfile.specChecksums[source.key] else { continue }
            if let path = source.value[.path] {
                localPods[source.key] = LocalPod(name: source.key, path: path, checksum: checksum)
            } else {
                remotePods[source.key] = RemotePod(name: source.key, options: source.value, checksum: checksum)
            }
        }

        let cachedLocalPods = Array(localPods.values)
        self.cachedLocalPods = cachedLocalPods
        let cachedRemotePods = Array(remotePods.values)
        self.cachedRemotePods = cachedRemotePods

        return (cachedLocalPods, cachedRemotePods)
    }
}

private extension String {
    static let path = ":path"
}
