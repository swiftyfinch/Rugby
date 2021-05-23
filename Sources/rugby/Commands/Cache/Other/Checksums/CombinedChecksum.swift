//
//  CombinedChecksum.swift
//  
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//

import Files

protocol CombinedChecksum {
    func combinedChecksum() throws -> Checksum
}

extension RemotePod: CombinedChecksum {
    func combinedChecksum() throws -> Checksum {
        let checksum = options
            .map { $0.key + ": " + $0.value }
            .sorted()
            .reduce(checksum.value) { ($0 + $1).sha1() }
        return Checksum(name: name, checksum: checksum)
    }
}

extension LocalPod: CombinedChecksum {
    func combinedChecksum() throws -> Checksum {
        let subfolders = try folder().subfolders
            .filter { !$0.name.contains("Test") }

        let subfoldersChecksums = subfolders.reduce(checksum.value) { checksum, subfolder in
            guard let subfolderChecksum = subfolder.generateChecksum() else { return checksum }
            return (checksum + subfolderChecksum).sha1()
        }

        return Checksum(name: name, checksum: subfoldersChecksums)
    }

    private func folder() throws -> Folder {
        let subpath = [path == "." ? nil : path, name]
            .compactMap { $0 }
            .joined(separator: "/")
        return try Folder.current.subfolder(at: subpath)
    }
}
