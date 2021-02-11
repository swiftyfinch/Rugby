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

        let buildedProductsDirToCacheFolder = buildedProducts.reduce(into: []) {
            $0.append(("${BUILT_PRODUCTS_DIR}/\($1)", "\(cacheFolder)/\($1)"))
        }
        try replaceContent(occurrences: buildedProductsDirToCacheFolder,
                           inFilesByRegEx: #".*-frameworks\.sh"#,
                           folder: supportFilesFolder)

        let podsConfigurationBuildDirToCacheFolder = buildedProducts.reduce(into: []) {
            $0.append(("${PODS_CONFIGURATION_BUILD_DIR}/\($1)", "\(cacheFolder)/\($1)"))
        }
        try replaceContent(occurrences: podsConfigurationBuildDirToCacheFolder,
                           inFilesByRegEx: #".*\.xcconfig"#,
                           folder: supportFilesFolder)
        try replaceContent(occurrences: buildedProductsDirToCacheFolder,
                           inFilesByRegEx: #".*-resources\.sh"#,
                           folder: supportFilesFolder)
        try replaceContent(occurrences: podsConfigurationBuildDirToCacheFolder,
                           inFilesByRegEx: #".*-resources\.sh"#,
                           folder: supportFilesFolder)
    }

    /// Replacing content of each file by regex criteria in selected folder.
    private func replaceContent(occurrences: [(lookup: String, replace: String)],
                                inFilesByRegEx fileRegEx: String,
                                folder: Folder) throws {
        let regex = try RegEx(pattern: fileRegEx)
        for file in folder.files.recursive where regex.test(file.path) {
            var content = try file.readAsString()
            for (lookup, replace) in occurrences {
                content = content.replacingOccurrences(of: lookup, with: replace)
            }
            try file.write(content)
        }
    }
}
