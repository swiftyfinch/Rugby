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
            autoreleasepool {
                guard let content = try? file.readAsString() else { return }
                if let existChecksum = checksum {
                    checksum = (existChecksum + content.sha1()).sha1()
                } else {
                    checksum = content.sha1()
                }
            }
        }
    }
}
