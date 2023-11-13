import Foundation

public extension String {
    /// Replaces the prefix with tilda if it equals to the home directory path.
    func homeFinderRelativePath() -> String {
        guard let homePath = ProcessInfo.processInfo.environment["HOME"] else { return self }
        return hasPrefix(homePath) ? "~\(dropFirst(homePath.count))" : self
    }
}
