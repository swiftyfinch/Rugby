import Foundation

private final class BundleToken {}

extension Bundle {
    static let resourcesBundle: Bundle! = {
        let currentBundle = Bundle(for: BundleToken.self)
        let resourcesBundleName = "LocalPodResources"
        let resourcesBundlePath: String! = currentBundle.path(forResource: resourcesBundleName, ofType: "bundle")
        return Bundle(path: resourcesBundlePath)
    }()
}
