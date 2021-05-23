//
//  CacheIntegration.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

struct CacheIntegration {
    let cacheFolder: String
    let buildedTargets: Set<String>

    func replacePathsToCache() throws {
        let supportFilesFolder = try Folder.current.subfolder(at: .podsTargetSupportFiles)
        let originalDirs = ["PODS_CONFIGURATION_BUILD_DIR", "BUILT_PRODUCTS_DIR"].joined(separator: "|")
        let suffixPods = buildedTargets.map { $0.escapeForRegex() }.joined(separator: "|")
        let fileRegex = [#".*-resources\.sh"#, #".*\.xcconfig"#, #".*-frameworks\.sh"#].joined(separator: "|")
        try FilePatcher().replace(#"\$\{(\#(originalDirs))\}(?=\/(\#(suffixPods))("|\s|\/))"#,
                                  with: cacheFolder,
                                  inFilesByRegEx: "(\(fileRegex))",
                                  folder: supportFilesFolder)
    }
}
