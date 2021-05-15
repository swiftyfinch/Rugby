//
//  Podfile+LocalChecksum.swift
//  
//
//  Created by Vyacheslav Khorkov on 15.05.2021.
//

import CommonCrypto
import Files
import Foundation

extension LocalPod {
    private var folder: Folder? {
        let subpath = [path == "." ? nil : path, name]
            .compactMap { $0 }
            .joined(separator: "/")
        return try? Folder.current.subfolder(at: subpath)
    }

    func folderChecksum() -> String? {
        guard let folder = folder else { return nil }
        let subfolderWithoutTests = folder.subfolders.filter { !$0.name.contains("Test") }
        return subfolderWithoutTests.reduce(into: nil) { checksum, subfolder in
            guard let subfolderChecksum = subfolder.generateChecksum() else { return }
            if let existChecksum = checksum {
                checksum = (existChecksum + subfolderChecksum).sha1()
            } else {
                checksum = subfolderChecksum
            }
        }
    }
}
