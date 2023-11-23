import ArgumentParser
import RugbyFoundation

extension GitHubUpdaterArchitecture: ExpressibleByArgument {}

struct Update: AsyncParsableCommand {
    private static let latestVersion = "latest"
    static var configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update Rugby version.",
        discussion: Links.commandsHelp("update.md"),
        subcommands: [List.self]
    )

    @Option(help: "Version, like 2.0.0.")
    var version = Update.latestVersion

    @Option(name: .shortAndLong, help: "Binary architecture: x86_64 or arm64.")
    var arch: GitHubUpdaterArchitecture?

    @Flag(help: "Allow install the latest pre-release version.")
    var beta = false

    @Flag(name: .shortAndLong, help: "Force an install even if Rugby is already installed.")
    var force = false

    @OptionGroup
    var commonOptions: CommonOptions

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.logLevel)
    }
}

extension Update {
    struct List: AsyncParsableCommand, RunnableCommand {
        static var configuration = CommandConfiguration(
            commandName: "list",
            abstract: "List of available versions."
        )

        @Option(help: "Maximum versions count.")
        var count = 5

        @OptionGroup
        var commonOptions: CommonOptions

        func run() async throws {
            try await run(body,
                          outputType: commonOptions.output,
                          logLevel: commonOptions.logLevel)
        }

        func body() async throws {
            let releases = try await dependencies.rugbyUpdater.list(count: count,
                                                                    minVersion: dependencies.settings.minUpdateVersion,
                                                                    binaryName: CommandLine.arguments[0])
            let currentVersion = releases.first { $0.version == Rugby.configuration.version }?.version
            for release in releases {
                var line = release.version
                if currentVersion == release.version { line = line.bold.green }
                if release.prerelease { line += " (Beta)".accent }
                await log(line)
            }
        }
    }
}

// MARK: - Body

extension Update: RunnableCommand {
    func body() async throws {
        dependencies.processMonitor.monitor()
        try await dependencies.rugbyUpdater.update(
            to: .init(
                newVersion: (version == Update.latestVersion) ? .latest : .some(version),
                current: Rugby.configuration.version,
                min: dependencies.settings.minUpdateVersion
            ),
            binaryName: CommandLine.arguments[0],
            allowBeta: beta,
            architecture: arch,
            force: force
        )
    }
}
