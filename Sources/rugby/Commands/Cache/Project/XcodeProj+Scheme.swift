//
//  XcodeProj+Scheme.swift
//  
//
//  Created by Vyacheslav Khorkov on 14.02.2021.
//

import Files

struct SchemeCleaner {
    func removeScheme(name: String, user: String) throws {
        let schemesFolder = try Folder(path: .podsProject + "/xcuserdata/\(user).xcuserdatad/xcschemes")
        try schemesFolder.file(at: name + ".xcscheme").delete()
    }
}
