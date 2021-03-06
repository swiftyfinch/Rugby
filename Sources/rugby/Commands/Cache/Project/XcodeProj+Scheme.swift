//
//  XcodeProj+Scheme.swift
//  
//
//  Created by Vyacheslav Khorkov on 14.02.2021.
//

import Files
import ShellOut

struct SchemeCleaner {
    func removeSchemes(pods: Set<String>, projectPath: String) throws {
        let username = try shellOut(to: "echo ${USER}")
        let schemeCleaner = SchemeCleaner()
        pods.forEach { try? schemeCleaner.removeScheme(name: $0, user: username, projectPath: projectPath) }
    }

    private func removeScheme(name: String, user: String, projectPath: String) throws {
        let schemesFolder = try Folder(path: projectPath + "/xcuserdata/\(user).xcuserdatad/xcschemes")
        try schemesFolder.file(at: name + ".xcscheme").delete()
    }
}
