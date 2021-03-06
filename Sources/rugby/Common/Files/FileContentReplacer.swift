//
//  FileContentReplacer.swift
//  
//
//  Created by Vyacheslav Khorkov on 03.03.2021.
//

import Files
import RegEx

struct FileContentReplacer {
    /// Replacing content of each file by regex criteria in selected folder.
    func replace(_ lookup: String,
                 with replace: String,
                 inFilesByRegEx fileRegEx: String,
                 folder: Folder) throws {
        let regex = try RegEx(pattern: fileRegEx)
        for file in folder.files.recursive where regex.test(file.path) {
            var content = try file.readAsString()
            content = content.replacingOccurrences(of: lookup, with: replace, options: .regularExpression)
            try file.write(content)
        }
    }
}
