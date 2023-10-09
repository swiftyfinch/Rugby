import Foundation

private final class BundleToken {}

extension Bundle {
    static let testResourcesBundle: Bundle! = {
        let currentBundle = Bundle(for: BundleToken.self)
        let resourcesBundleName = "LocalPodResourceBundleTestsResources"
        let resourcesBundlePath: String! = currentBundle.path(forResource: resourcesBundleName, ofType: "bundle")
        return Bundle(path: resourcesBundlePath)
    }()
}
