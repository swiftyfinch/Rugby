//
//  FilePatcher.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 03.03.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

struct FilePatcher {
    /// Replacing content of each file by regex criteria in selected folder.
    func replace(_ lookup: String,
                 with replace: String,
                 inFilesByRegEx fileRegEx: String,
                 folder: Folder) throws {
        let regex = try fileRegEx.regex()
        for file in folder.files.recursive where file.path.match(regex) {
            try autoreleasepool {
                var content = try file.readAsString()
                content = content.replacingOccurrences(of: lookup, with: replace, options: .regularExpression)
                try file.write(content)
            }
        }
    }
}
