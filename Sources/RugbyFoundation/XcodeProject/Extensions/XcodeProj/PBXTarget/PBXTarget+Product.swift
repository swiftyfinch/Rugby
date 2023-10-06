import XcodeProj

extension PBXTarget {
    func constructProduct(_ buildSettings: BuildSettings?) throws -> Product? {
        guard let buildSettings,
              let productName = buildSettings["PRODUCT_NAME"] as? String,
              let productType else { return nil }
        let configurationBuildDir = buildSettings["CONFIGURATION_BUILD_DIR"] as? String
        let parentName = configurationBuildDir?.components(separatedBy: "/").last
        let productModuleName = buildSettings["PRODUCT_MODULE_NAME"] as? String
        return Product(
            name: productName,
            moduleName: productModuleName,
            type: productType,
            parentFolderName: parentName
        )
    }
}
