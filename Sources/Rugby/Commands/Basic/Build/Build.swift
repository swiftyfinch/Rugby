import ArgumentParser
import Fish
import RugbyFoundation

struct Build: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build targets from Pods project.",
        discussion: Links.commandsHelp("build.md"),
        subcommands: [Build.Full.self, Build.Pre.self],
        defaultSubcommand: Build.Full.self
    )
}

// MARK: - Full Build Subcommand

extension Build {
    struct Full: AsyncParsableCommand, RunnableCommand {
        static var configuration = CommandConfiguration(
            commandName: "full",
            abstract: "Build targets as is.",
            discussion: Links.commandsHelp("build/full.md")
        )

        @Flag(name: .long, help: "Ignore shared cache.")
        var ignoreCache = false

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
            dependencies.processMonitor.monitor()
            try await dependencies.buildManager(workingDirectory: Folder.current).build(
                targetsRegex: regex(
                    patterns: buildOptions.targetsOptions.targetsAsRegex,
                    exactMatches: buildOptions.targetsOptions.targets
                ),
                exceptTargetsRegex: regex(
                    patterns: buildOptions.targetsOptions.exceptAsRegex,
                    exactMatches: buildOptions.targetsOptions.exceptTargets
                ),
                options: buildOptions.xcodeBuildOptions(),
                paths: dependencies.xcode.paths(
                    workingDirectory: Folder.current,
                    logsFolder: dependencies.logsRotator.currentLogFolder()
                ),
                ignoreCache: ignoreCache
            )
        }
    }
}

// MARK: - Pre Build Subcommand

extension Build {
    struct Pre: AsyncParsableCommand, RunnableCommand {
        static var configuration = CommandConfiguration(
            commandName: "pre",
            abstract: "Prebuild targets ignoring sources.",
            discussion: Links.commandsHelp("build/pre.md")
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
            dependencies.processMonitor.monitor()
            let logFolder = try dependencies.logsRotator.currentLogFolder().createFolder(named: "prebuild")
            let prebuildManager = dependencies.prebuildManager(workingDirectory: Folder.current)
            try await prebuildManager.prebuild(
                targetsRegex: regex(
                    patterns: buildOptions.targetsOptions.targetsAsRegex,
                    exactMatches: buildOptions.targetsOptions.targets
                ),
                exceptTargetsRegex: regex(
                    patterns: buildOptions.targetsOptions.exceptAsRegex,
                    exactMatches: buildOptions.targetsOptions.exceptTargets
                ),
                options: buildOptions.xcodeBuildOptions(skipSigning: true),
                paths: dependencies.xcode.paths(workingDirectory: Folder.current, logsFolder: logFolder)
            )
        }
    }
}
