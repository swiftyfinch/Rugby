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
        pods.forEach {
            let sharedSchemes = try? Folder(path: projectPath + "/xcshareddata/xcschemes")
            try? sharedSchemes?.file(at: $0 + ".xcscheme").delete()
        }

        let username = try shellOut(to: "echo ${USER}")
        pods.forEach {
            let userSchemesFolder = try? Folder(path: projectPath + "/xcuserdata/\(username).xcuserdatad/xcschemes")
            try? userSchemesFolder?.file(at: $0 + ".xcscheme").delete()
        }
    }
}
