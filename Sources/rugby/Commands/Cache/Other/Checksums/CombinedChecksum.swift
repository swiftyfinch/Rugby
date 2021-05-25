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
            .map { $0.key + ":" + $0.value }
            .sorted()
            .reduce(checksum.value) { calculateChecksum($0, $1) }
        return Checksum(name: name, checksum: checksum)
    }
}

extension LocalPod: CombinedChecksum {
    func combinedChecksum() throws -> Checksum {
        let rootFolder = try folder()
        let subfolders = rootFolder.subfolders
            .filter { !$0.name.contains("Test") }
        let subfoldersChecksum = subfolders.reduce(into: checksum.value) { checksum, subfolder in
            guard let subfolderChecksum = subfolder.generateChecksum() else { return }
            checksum = calculateChecksum(checksum, subfolderChecksum)
        }

        let finalChecksum = rootFolder.files.reduce(into: subfoldersChecksum) { checksum, file in
            guard let fileChecksum = file.generateChecksum() else { return }
            checksum = calculateChecksum(checksum, fileChecksum)
        }

        return Checksum(name: name, checksum: finalChecksum)
    }

    private func folder() throws -> Folder {
        let subpath = path == "." ? name : path
        return try Folder.current.subfolder(at: subpath)
    }
}

func calculateChecksum(_ values: String...) -> String {
    values.joined(separator: "|").sha1()
}
