import Foundation

private final class BundleToken {}

extension Bundle {
    static let testResourcesBundle = Bundle(for: BundleToken.self)
}
