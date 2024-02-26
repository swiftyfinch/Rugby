import Foundation

enum BuildError: LocalizedError, Equatable {
    case buildFailed(errors: [String], buildLogPath: String, rawBuildLogPath: String)
    case cantFindBuildTargets

    var errorDescription: String? {
        switch self {
        case let .buildFailed(errors, buildLogPath, rawBuildLogPath):
            return """
            \("Xcodebuild failed.".red)
            \(errors.map(formatBuildError).joined(separator: "\n").white)
            \("🚑 More information in build logs:".yellow)
            \("[Beautified]".yellow) \("cat \(buildLogPath.homeFinderRelativePath())".white.applyingStyle(.default))
            \("[Raw]".yellow) \("open \(rawBuildLogPath.homeFinderRelativePath())".white.applyingStyle(.default))
            """
        case .cantFindBuildTargets:
            return "Couldn't find any build targets."
        }
    }

    private func formatBuildError(_ errorText: String) -> String {
        let errorText = errorText.raw.hasPrefix("✖") ? errorText : "\("✖".red) \(errorText)"
        return errorText
            .components(separatedBy: "\n")
            .map { " \($0)" }
            .joined(separator: "\n")
    }
}
