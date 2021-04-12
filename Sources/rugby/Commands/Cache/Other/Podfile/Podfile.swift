//
//  Podfile.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

struct Podfile {
    let path: String
    let file: File

    init(_ path: String) throws {
        self.path = path
        self.file = try Folder.current.file(at: path)
    }

    func read() throws -> String {
        try file.readAsString()
    }
}
