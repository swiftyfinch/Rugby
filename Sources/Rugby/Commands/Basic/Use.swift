//
//  Use.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 19.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Fish
import RugbyFoundation

struct Use: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "use",
        abstract: "Use already built binaries instead of sources.",
        discussion: Links.commandsHelp("use.md")
    )

    @Flag(name: .long, help: "Delete target groups from project.")
    var deleteSources = false

    @OptionGroup
    var targetsOptions: TargetsOptions

    @OptionGroup
    var additionalBuildOptions: AdditionalBuildOptions

    @OptionGroup
    var commonOptions: CommonOptions

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.verbose)
    }
}

// MARK: - Body

extension Use: RunnableCommand {
    func body() async throws {
        try await dependencies.useBinariesManager(workingDirectory: Folder.current)
            .use(
                targetsRegex: try regex(
                    patterns: targetsOptions.targetsAsRegex,
                    exactMatches: targetsOptions.targets
                ),
                exceptTargetsRegex: try regex(
                    patterns: targetsOptions.exceptAsRegex,
                    exactMatches: targetsOptions.exceptTargets
                ),
                xcargs: dependencies.xcargsProvider.xcargs(strip: additionalBuildOptions.strip),
                deleteSources: deleteSources
            )
    }
}
