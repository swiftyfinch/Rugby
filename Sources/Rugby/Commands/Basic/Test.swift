import ArgumentParser

struct Test: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "_test",
        abstract: "\("(Beta)".yellow) Analyse test targets.",
        discussion: Links.commandsHelp("test.md"),
        subcommands: [Impact.self, Passed.self]
    )

    func run() async throws {
        let commandInfo = try HelpDumper().dump(command: Test.self)
        HelpPrinter().print(command: commandInfo)
    }
}

private extension Test {
    struct Impact: RunnableCommand {
        static var configuration = CommandConfiguration(
            commandName: "impact",
            abstract: "\("(Beta)".yellow) Print affected test targets.",
            discussion: Links.commandsHelp("test/impact.md")
        )

        @OptionGroup
        var buildOptions: BuildOptions

        @OptionGroup
        var commonOptions: CommonOptions

        func run() async throws {
            try await run(body,
                          outputType: commonOptions.output,
                          logLevel: commonOptions.logLevel)
        }

        func body() async throws {
            try await dependencies.testManager()
                .impact(
                    targetsRegex: regex(
                        patterns: buildOptions.targetsOptions.targetsAsRegex,
                        exactMatches: buildOptions.targetsOptions.targets
                    ),
                    exceptTargetsRegex: regex(
                        patterns: buildOptions.targetsOptions.exceptAsRegex,
                        exactMatches: buildOptions.targetsOptions.exceptTargets
                    ),
                    buildOptions: buildOptions.xcodeBuildOptions()
                )
        }
    }
}

private extension Test {
    struct Passed: RunnableCommand {
        static var configuration = CommandConfiguration(
            commandName: "pass",
            abstract: "\("(Beta)".yellow) Mark test targets as passed.",
            discussion: Links.commandsHelp("test/pass.md")
        )

        @OptionGroup
        var buildOptions: BuildOptions

        @OptionGroup
        var commonOptions: CommonOptions

        func run() async throws {
            try await run(body,
                          outputType: commonOptions.output,
                          logLevel: commonOptions.logLevel)
        }

        func body() async throws {
            try await dependencies.testManager()
                .markAsPassed(
                    targetsRegex: regex(
                        patterns: buildOptions.targetsOptions.targetsAsRegex,
                        exactMatches: buildOptions.targetsOptions.targets
                    ),
                    exceptTargetsRegex: regex(
                        patterns: buildOptions.targetsOptions.exceptAsRegex,
                        exactMatches: buildOptions.targetsOptions.exceptTargets
                    ),
                    buildOptions: buildOptions.xcodeBuildOptions()
                )
        }
    }
}
