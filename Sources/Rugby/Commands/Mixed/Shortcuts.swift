import ArgumentParser
import Fish
import RugbyFoundation

struct Shortcuts: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "shortcuts",
        abstract: "Set of base commands combinations.",
        discussion: Links.commandsHelp("shortcuts.md"),
        subcommands: [Umbrella.self, Cache.self],
        defaultSubcommand: Umbrella.self
    )
}

extension Shortcuts {
    struct Umbrella: AsyncParsableCommand, AnyArgumentsCommand {
        static var configuration = CommandConfiguration(
            commandName: "umbrella",
            abstract: """
            Run the \("plan".accent) command if plans file exists \
            or run the \("cache".accent) command.
            """,
            discussion: Links.commandsHelp("shortcuts/umbrella.md")
        )

        @Argument(help: "Any arguments of \("plan".accent) or \("cache".accent) commands.")
        var arguments: [String] = []

        func run() async throws {
            try await body()
        }
    }
}

extension Shortcuts.Umbrella: RunnableCommand {
    func body() async throws {
        let plansPath: String
        if let pathIndex = arguments.firstIndex(where: { $0 == "--path" || $0 == "-p" }),
           arguments.count > pathIndex + 1 {
            plansPath = arguments[pathIndex + 1]
        } else {
            plansPath = dependencies.router.plansRelativePath
        }

        let parsedCommand: ParsableCommand
        if File.isExist(at: Folder.current.subpath(plansPath)) {
            parsedCommand = try Plan.parseAsRoot(arguments)
        } else {
            parsedCommand = try Shortcuts.Cache.parseAsRoot(arguments)
        }
        var runnableCommand = try parsedCommand.toRunnable()
        try await runnableCommand.run()
    }
}

// MARK: - Cache Subcommand

extension Shortcuts {
    struct Cache: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "cache",
            abstract: "Run the \("build".accent) and \("use".accent) commands.",
            discussion: Links.commandsHelp("shortcuts/cache.md")
        )

        @Flag(name: .shortAndLong, help: "Restore projects state before the last Rugby usage.")
        var rollback = false

        @Flag(name: .long, help: "Prebuild targets ignoring sources.")
        var prebuild = false

        @Option(help: "Warmup cache with this endpoint.")
        var warmup: String?

        @OptionGroup
        var buildOptions: BuildOptions

        @Flag(name: .long, help: "Ignore shared cache.")
        var ignoreCache = false

        @Option(name: .long, help: "Path to xcresult bundle.")
        var resultBundlePath: String?

        @Flag(name: .long, help: "Delete target groups from project.")
        var deleteSources = false

        @OptionGroup
        var commonOptions: CommonOptions

        func run() async throws {
            try await run(body,
                          outputType: commonOptions.output,
                          logLevel: commonOptions.logLevel)
        }
    }
}

extension Shortcuts.Cache: RunnableCommand {
    func body() async throws {
        var runnableCommands: [(name: String, RunnableCommand)] = []

        if rollback {
            var rollback = Rollback()
            rollback.commonOptions = commonOptions
            runnableCommands.append(("Rollback", rollback))
        }

        if prebuild {
            var prebuild = Build.Pre()
            prebuild.buildOptions = buildOptions
            prebuild.commonOptions = commonOptions
            runnableCommands.append(("Prebuild", prebuild))
        }

        if let endpoint = warmup {
            var warmup = Warmup()
            warmup.endpoint = endpoint
            warmup.analyse = false
            warmup.buildOptions = buildOptions
            warmup.commonOptions = commonOptions
            warmup.timeout = Self.settings.warmupTimeout
            warmup.maxConnections = Self.settings.warmupMaximumConnectionsPerHost
            runnableCommands.append(("Warmup", warmup))
        }

        var build = Build.Full()
        build.buildOptions = buildOptions
        build.ignoreCache = ignoreCache
        build.resultBundlePath = resultBundlePath
        build.commonOptions = commonOptions
        runnableCommands.append(("Build", build))

        var use = Use()
        use.deleteSources = deleteSources
        use.targetsOptions = buildOptions.targetsOptions
        use.additionalBuildOptions = buildOptions.additionalBuildOptions
        use.commonOptions = commonOptions
        runnableCommands.append(("Use", use))

        for (name, command) in runnableCommands {
            try await log(name.green) {
                try await command.body()
            }
        }
    }
}
