import XcodeProj

extension PBXTarget {
    func constructProduct(_ buildSettings: BuildSettings?) throws -> Product? {
        guard let buildSettings,
              let productName = buildSettings["PRODUCT_NAME"]?.stringValue,
              let productType else { return nil }
        let configurationBuildDir = buildSettings["CONFIGURATION_BUILD_DIR"]?.stringValue
        let parentName = configurationBuildDir?.components(separatedBy: "/").last
        let productModuleName = buildSettings["PRODUCT_MODULE_NAME"]?.stringValue
        return Product(
            name: productName,
            moduleName: productModuleName,
            type: productType,
            parentFolderName: parentName
        )
    }
}
