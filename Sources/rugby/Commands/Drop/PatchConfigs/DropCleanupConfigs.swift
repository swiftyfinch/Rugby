//
//  DropCleanupConfigs.swift
//  
//
//  Created by Vyacheslav Khorkov on 02.03.2021.
//

import Files
import RegEx

struct DropUpdateConfigs {
    let products: Set<String>

    func removeProducts() throws {
        let supportFilesFolder = try Folder.current.subfolder(at: .podsTargetSupportFiles)
        let productsRegex = "(" + productsNames().map { $0.escapeForRegex() }.joined(separator: "|") + ")"
        let lookupMatches = [
            #" *install_framework "\$\{BUILT_PRODUCTS_DIR\}.*\#(productsRegex)\.framework"\n"#,
            #" ?(-iframework )?"\$\{PODS_CONFIGURATION_BUILD_DIR\}\/\#(productsRegex)""#,
            #"(-isystem )?"\$\{PODS_CONFIGURATION_BUILD_DIR\}\/\S+\/\#(productsRegex).framework\/Headers""#,
            #"-framework "\#(productsRegex)""#,
            #" *install_resource "\$\{PODS_CONFIGURATION_BUILD_DIR\}.*\#(productsRegex)\.bundle"\n"#
        ]
        let fileRegex = [#".*-resources\.sh"#, #".*\.xcconfig"#, #".*-frameworks\.sh"#].joined(separator: "|")
        try FilePatcher().replace("(" + lookupMatches.joined(separator: "|") + ")",
                                          with: "",
                                          inFilesByRegEx: "(\(fileRegex))",
                                          folder: supportFilesFolder)
    }

    private func productsNames() -> [String] {
        products.map {
            $0.removingSuffix(".framework").removingSuffix(".bundle")
        }
    }
}

private extension String {
    func removingSuffix(_ suffix: String) -> String {
        hasSuffix(suffix) ? String(dropLast(suffix.count)) : self
    }
}
