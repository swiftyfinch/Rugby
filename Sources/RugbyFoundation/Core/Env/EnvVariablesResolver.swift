// MARK: - Interface

protocol IEnvVariablesResolver: AnyObject {
    func resolve(
        _ string: String,
        additionalEnv: [String: String]
    ) async throws -> String
}

extension IEnvVariablesResolver {
    func resolve(_ string: String) async throws -> String {
        try await resolve(string, additionalEnv: [:])
    }
}

// MARK: - Implementation

final class EnvVariablesResolver: Loggable {
    let logger: ILogger
    private let env: [String: String]
    private let regex = #"\$[\{\(]?([a-zA-Z0-9_]+)[\}\)]?"#

    init(logger: ILogger, env: [String: String]) {
        self.logger = logger
        self.env = env
    }
}

extension EnvVariablesResolver: IEnvVariablesResolver {
    func resolve(_ string: String, additionalEnv: [String: String]) async throws -> String {
        var resolvedPath = string
        var replaced = true
        while replaced {
            replaced = false
            let groups = try resolvedPath.groups(regex: regex)
            guard groups.count == 2 else { continue }
            let (match, variable) = (groups[0], groups[1])
            guard let replace = env[variable] ?? additionalEnv[variable] else {
                await log("Can't find \(match) environment variable.", level: .info)
                continue
            }
            resolvedPath = resolvedPath.replacingOccurrences(of: match, with: replace)
            replaced = true
        }
        return resolvedPath
    }
}
