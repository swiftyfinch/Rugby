import Foundation
import XcodeProj

extension PBXTarget {
    /// Collects paths for each XCConfig file
    func xcconfigPaths() -> [String] {
        guard let buildConfigurations = buildConfigurationList?.buildConfigurations else { return [] }
        return buildConfigurations.compactMap(\.baseConfiguration).compactMap(\.fullPath)
    }

    /// Returns path to `${name}-frameworks.sh`
    func frameworksScriptPath(xcconfigPaths: [String]) -> String? {
        guard let xcconfigPath = xcconfigPaths.first.map(URL.init(fileURLWithPath:)) else { return nil }
        return xcconfigPath.deletingLastPathComponent().appendingPathComponent("\(name)-frameworks.sh").path
    }

    /// Returns path to `${name}-resources.sh`
    func resourcesScriptPath(xcconfigPaths: [String]) -> String? {
        guard let xcconfigPath = xcconfigPaths.first.map(URL.init(fileURLWithPath:)) else { return nil }
        return xcconfigPath.deletingLastPathComponent().appendingPathComponent("\(name)-resources.sh").path
    }
}
