import XcodeProj

extension PBXTarget {
    /// Checks if target is tests bundle or tests AppHost
    var isTests: Bool {
        let isUnitTests = (productType == .unitTestBundle)
        let isUITests = (productType == .uiTestBundle)
        let isTestsAppHost = (productType == .application) && name.contains("AppHost")
        return isUnitTests || isUITests || isTestsAppHost
    }
}
