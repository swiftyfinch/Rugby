import Foundation

extension Bundle {
    private static let bundleName = "LocalPodResources"

    static let resourcesBundle = Bundle.main.path(forResource: bundleName, ofType: "bundle").flatMap(Bundle.init) ??
        Bundle(for: BundleToken.self).path(forResource: bundleName, ofType: "bundle").flatMap(Bundle.init) ??
        Bundle(for: BundleToken.self)
}

private final class BundleToken {}
