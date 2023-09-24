//
//  Warmup.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 16.01.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Fish
import Foundation
import RugbyFoundation

struct Warmup: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "warmup",
        abstract: "Download remote binaries for targets from Pods project.",
        discussion: """
        \(Links.commandsHelp("warmup.md"))
        \(Links.docs("remote-cache.md"))
        """
    )

    @Argument(help: "Endpoint for your binaries storage (s3.eu-west-2.amazonaws.com)")
    var endpoint: String?

    @Flag(help: "Run only in analyse mode without downloading. The endpoint is optional.")
    var analyse = false

    @OptionGroup
    var buildOptions: BuildOptions

    @OptionGroup
    var commonOptions: CommonOptions

    @Option(help: "Timeout for requests in seconds.")
    var timeout = settings.warmupTimeout

    @Option(help: "The maximum number of simultaneous connections.")
    var maxConnections = settings.warmupMaximumConnectionsPerHost

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.verbose)
    }
}

// MARK: - Body

extension Warmup: RunnableCommand {
    enum Error: LocalizedError {
        case missingEndpoint

        var errorDescription: String? {
            switch self {
            case .missingEndpoint:
                return "Missing endpoint."
            }
        }
    }

    func body() async throws {
        let mode: WarmupMode
        switch (analyse, endpoint) {
        case (true, let endpoint):
            mode = .analyse(endpoint: endpoint)
        case (false, let endpoint?):
            mode = .endpoint(endpoint)
        case (false, nil):
            throw Error.missingEndpoint
        }
        try await dependencies.warmupManager(
            workingDirectory: Folder.current,
            timeoutIntervalForRequest: TimeInterval(timeout),
            httpMaximumConnectionsPerHost: maxConnections
        ).warmup(
            mode: mode,
            targetsRegex: try regex(
                patterns: buildOptions.targetsOptions.targetsAsRegex,
                exactMatches: buildOptions.targetsOptions.targets
            ),
            exceptTargetsRegex: try regex(
                patterns: buildOptions.targetsOptions.exceptAsRegex,
                exactMatches: buildOptions.targetsOptions.exceptTargets
            ),
            options: buildOptions.xcodeBuildOptions(),
            maxInParallel: maxConnections
        )
    }
}
