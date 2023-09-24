//
//  XcodeEnvResolver.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 08.11.2022.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

final class XcodeEnvResolver: Loggable {
    let logger: ILogger
    private let env: [String: String]
    private let regex = #"\$[\{|\(][^}]*?[\}|\)]"#

    init(logger: ILogger, env: [String: String]) {
        self.logger = logger
        self.env = env
    }

    func resolve(path: String, additionalEnv: [String: String]) async throws -> String {
        var resolvedPath = path
        var replaced = true
        while replaced {
            replaced = false
            let matches = try resolvedPath.groups(regex: regex)
            resolvedPath = await matches.reduce(into: resolvedPath) { path, match in
                let variable = String(match.dropFirst(2).dropLast(1)) // Drop ${ and }
                guard let replace = env[variable] ?? additionalEnv[variable] else {
                    await log("Can't find \(match) environment variable.", level: .info)
                    return
                }
                path = path.replacingOccurrences(of: match, with: replace)
                replaced = true
            }
        }
        return resolvedPath
    }
}
