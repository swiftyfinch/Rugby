import Foundation
import XcodeProj

extension PBXTarget {
    /// Collects paths for each XCConfig file
    func xcconfigPaths() -> Set<String> {
        guard let buildConfigurations = buildConfigurationList?.buildConfigurations else { return [] }
        return buildConfigurations.compactMap(\.baseConfiguration).compactMap(\.fullPath).set()
    }

    /// Returns path to `${name}-frameworks.sh`
    func frameworksScriptPath(xcconfigPaths: Set<String>) -> String? {
        guard let xcconfigPath = xcconfigPaths.first.map(URL.init(fileURLWithPath:)) else { return nil }
        return xcconfigPath.deletingLastPathComponent().appendingPathComponent("\(name)-frameworks.sh").path
    }

    /// Returns path to `${name}-resources.sh`
    func resourcesScriptPath(xcconfigPaths: Set<String>) -> String? {
        guard let xcconfigPath = xcconfigPaths.first.map(URL.init(fileURLWithPath:)) else { return nil }
        return xcconfigPath.deletingLastPathComponent().appendingPathComponent("\(name)-resources.sh").path
    }
}
