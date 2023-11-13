import ArgumentParser
import Fish

struct Env: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "env",
        abstract: "Print Rugby environment.",
        discussion: Links.commandsHelp("env.md")
    )

    func run() async throws {
        try await dependencies.environmentCollector.env(
            rugbyVersion: Rugby.configuration.version,
            rugbyEnvironment: dependencies.featureToggles.all
        ).forEach { print($0) }
    }
}
