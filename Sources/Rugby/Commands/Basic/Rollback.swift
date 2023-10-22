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
                      logLevel: commonOptions.logLevel,
                      muteSound: true)
    }

    func body() async throws {
        try await dependencies.backupManager(workingDirectory: Folder.current)
            .restore(.original)
        dependencies.xcode.resetProjectsCache()
    }
}
