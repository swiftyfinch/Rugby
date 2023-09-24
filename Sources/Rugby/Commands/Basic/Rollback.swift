//
//  Rollback.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 12.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Fish
import RugbyFoundation

struct Rollback: RunnableCommand {
    static var configuration = CommandConfiguration(
        commandName: "rollback",
        abstract: "Restore projects state before the last Rugby usage.",
        discussion: Links.commandsHelp("rollback.md")
    )

    @OptionGroup
    var commonOptions: CommonOptions

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.verbose,
                      muteSound: true)
    }

    func body() async throws {
        try await dependencies.backupManager(workingDirectory: Folder.current)
            .restore(.original)
        dependencies.xcode.resetProjectsCache()
    }
}
