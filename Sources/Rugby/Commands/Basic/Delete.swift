//
//  Delete.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 01.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Fish
import RugbyFoundation

struct Delete: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete targets from the project.",
        discussion: Links.commandsHelp("delete.md")
    )

    @Option(name: .shortAndLong, help: "Project location.")
    var path = dependencies.router.podsProjectRelativePath

    @Flag(name: .long, help: "Keep dependencies of excepted targets.")
    var safe = false

    @Flag(name: .long, help: "Delete target groups from project.")
    var deleteSources = false

    @OptionGroup
    var targetsOptions: TargetsOptions

    @OptionGroup
    var commonOptions: CommonOptions

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.verbose)
    }
}

// MARK: - Body

extension Delete: RunnableCommand {
    func body() async throws {
        let deleteTargetsManager = dependencies.deleteTargetsManager(
            workingDirectory: Folder.current,
            projectPath: path
        )
        try await deleteTargetsManager.delete(
            targetsRegex: try regex(
                patterns: targetsOptions.targetsAsRegex,
                exactMatches: targetsOptions.targets
            ),
            exceptTargetsRegex: try regex(
                patterns: targetsOptions.exceptAsRegex,
                exactMatches: targetsOptions.exceptTargets
            ),
            keepExceptedTargetsDependencies: safe,
            deleteSources: deleteSources
        )
    }
}
