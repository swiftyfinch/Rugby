import Foundation

extension String {
    func homeEnvRelativePath() -> String {
        guard let homePath = ProcessInfo.processInfo.environment["HOME"] else { return self }
        return hasPrefix(homePath) ? "${HOME}\(dropFirst(homePath.count))" : self
    }
}
