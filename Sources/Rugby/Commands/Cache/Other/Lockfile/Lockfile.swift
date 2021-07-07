//
//  Lockfile.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Yams

struct Lockfile {
    enum LockFileError: Error {
        case incorrectObject(String)
    }

    let specChecksums: [String: Checksum]
    let externalSources: [String: [String: String]]
    let specRepos: [String: [String]]

    init(path: String) throws {
        let file = try Folder.current.file(at: path)
        let content = try file.readAsString()
        guard let yaml = try load(yaml: content) as? [String: Any] else {
            throw LockFileError.incorrectObject(.root)
        }
        self.specChecksums = try Self.parseSpecChecksums(yaml)
        self.externalSources = try Self.parseExternalSources(yaml)
        self.specRepos = try Self.parseSpecRepos(yaml)
    }

    private static func parseSpecChecksums(_ object: [String: Any]) throws -> [String: Checksum] {
        try ((object[.specChecksums] ?? [:]) as? [String: String])
            .unwrap(orThrow: LockFileError.incorrectObject(.specChecksums))
            .mapDictionary(transform: { ($0.key, Checksum(name: $0.key, checksum: $0.value)) })
    }

    private static func parseExternalSources(_ object: [String: Any]) throws -> [String: [String: String]] {
        try ((object[.externalSources] ?? [:]) as? [String: [String: String]])
            .unwrap(orThrow: LockFileError.incorrectObject(.externalSources))
    }

    private static func parseSpecRepos(_ object: [String: Any]) throws -> [String: [String]] {
        try ((object[.specRepos] ?? [:]) as? [String: [String]])
            .unwrap(orThrow: LockFileError.incorrectObject(.specRepos))
    }
}

private extension String {
    static let root = "ROOT"
    static let specChecksums = "SPEC CHECKSUMS"
    static let externalSources = "EXTERNAL SOURCES"
    static let specRepos = "SPEC REPOS"
    static let checkoutOptions = "CHECKOUT OPTIONS"
}
