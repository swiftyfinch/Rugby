import Foundation

enum BuildError: LocalizedError {
    case buildFailed(errors: [String], buildLogPath: String, rawBuildLogPath: String)
    case cantFindBuildTargets

    var errorDescription: String? {
        switch self {
        case let .buildFailed(errors, buildLogPath, rawBuildLogPath):
            return """
            \("Build failed.".red)
            \(errors.map(formatBuildError).joined(separator: "\n").white)
            \("🚑 More information in build logs:".yellow)
            \("[Beautified]".yellow) \("cat \(buildLogPath.homeFinderRelativePath())".white)
            \("[Raw]".yellow) \("open \(rawBuildLogPath.homeFinderRelativePath())".white)
            """
        case .cantFindBuildTargets:
            return "Couldn't find any build targets."
        }
    }

    private func formatBuildError(_ errorText: String) -> String {
        "\("\u{2716}\u{0000FE0E}".red) \(errorText)"
            .components(separatedBy: "\n")
            .map { " \($0)" }
            .joined(separator: "\n")
    }
}
