//
//  Folder+Checksum.swift
//  
//
//  Created by Vyacheslav Khorkov on 15.05.2021.
//

import Files
import Foundation

extension Folder {
    func generateChecksum() -> String? {
        files.recursive.reduce(into: nil) { checksum, file in
            guard let fileChecksum = file.generateChecksum() else { return }
            if let existChecksum = checksum {
                checksum = calculateChecksum(existChecksum, fileChecksum)
            } else {
                checksum = fileChecksum
            }
        }
    }
}

extension File {
    func generateChecksum() -> String? {
        autoreleasepool {
            return try? calculateChecksum(readAsString())
        }
    }
}
