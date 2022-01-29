//
//  CacheIntegration.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct CacheIntegration {
    let cacheXCFolder: String
    let cacheFolder: String
    let builtTargets: Set<String>

    func replacePathsToCache() throws {
        let supportFilesFolder = try Folder.current.subfolder(at: .podsTargetSupportFiles)
        let originalDirs = ["PODS_CONFIGURATION_BUILD_DIR", "BUILT_PRODUCTS_DIR"].joined(separator: "|")
        let suffixPods = builtTargets.map { $0.escapeForRegex() }.joined(separator: "|")
        let fileRegex = [#".*-resources\.sh"#, #".*\.xcconfig"#, #".*-frameworks\.sh"#].joined(separator: "|")
        let filePatcher = FilePatcher()
        try filePatcher.replace(#"\$\{(\#(originalDirs))\}(?=\/(\#(suffixPods))("|\s|\/))"#,
                                  with: cacheFolder,
                                  inFilesByRegEx: "(\(fileRegex))",
                                  folder: supportFilesFolder)
        try filePatcher.append(cacheXCConfig: cacheXCFolder,
                               inFilesByRegEx: "(\(fileRegex))",
                               folder: supportFilesFolder)
    }
}
