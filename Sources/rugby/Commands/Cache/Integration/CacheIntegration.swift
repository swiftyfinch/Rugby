//
//  CacheIntegration.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import RegEx

struct CacheIntegration {
    let cacheFolder: String
    let buildedProducts: Set<String>

    func replacePathsToCache() throws {
        let supportFilesFolder = try Folder.current.subfolder(at: .podsTargetSupportFiles)
        let originalDirs = ["PODS_CONFIGURATION_BUILD_DIR", "BUILT_PRODUCTS_DIR"].joined(separator: "|")
        let suffixPods = buildedProducts.map { $0.escapeForRegex() }.joined(separator: "|")
        let fileRegex = [#".*-resources\.sh"#, #".*\.xcconfig"#, #".*-frameworks\.sh"#].joined(separator: "|")
        try replace(#"\$\{(\#(originalDirs))\}(?=\/(\#(suffixPods))\b)"#,
                    with: cacheFolder,
                    inFilesByRegEx: "(\(fileRegex))",
                    folder: supportFilesFolder)
    }

    /// Replacing content of each file by regex criteria in selected folder.
    private func replace(_ lookup: String,
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
