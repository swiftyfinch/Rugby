import ArgumentParser
import Fish
import RugbyFoundation

struct Build: AsyncParsableCommand, RunnableCommand {
    static var configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build targets from Pods project.",
        discussion: Links.commandsHelp("build.md")
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
            paths: dependencies.xcode.paths(workingDirectory: Folder.current),
            ignoreCache: ignoreCache
        )
    }
}
