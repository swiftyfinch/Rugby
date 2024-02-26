import ArgumentParser

struct Test: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "_test",
        abstract: "\("(Experimental)".yellow) Analyse and run tests.",
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
            abstract: "\("(Experimental)".yellow) Print affected test targets.",
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
            try await dependencies.testImpactManager()
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
            abstract: "\("(Experimental)".yellow) Mark test targets as passed.",
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
            try await dependencies.testImpactManager()
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
