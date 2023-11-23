import Foundation

public extension Error {
    /// Returns error description in beautiful way.
    var beautifulDescription: String {
        let localizedDescription = (self as? LocalizedError)?.errorDescription
        return localizedDescription ?? String(describing: self)
    }
}
