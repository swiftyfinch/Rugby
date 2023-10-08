import Foundation

extension Bundle {
    private static let bundleName = "LocalPodTestsResources"

    static let testResourcesBundle = Bundle.main.path(forResource: bundleName, ofType: "bundle").flatMap(Bundle.init) ??
        Bundle(for: BundleToken.self).path(forResource: bundleName, ofType: "bundle").flatMap(Bundle.init) ??
        Bundle(for: BundleToken.self)
}

private final class BundleToken {}
