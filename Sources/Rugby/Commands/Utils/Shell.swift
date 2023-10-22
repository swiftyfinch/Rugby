import ArgumentParser

struct Shell: RunnableCommand {
    static let configuration = CommandConfiguration(
        commandName: "shell",
        abstract: "Run shell command from Rugby.",
        discussion: Links.commandsHelp("shell.md")
    )

    @Argument(help: "Shell script command.")
    var command: String

    @OptionGroup
    var commonOptions: CommonOptions

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.logLevel,
                      muteSound: false)
    }

    func body() async throws {
        dependencies.processMonitor.monitor()
        switch commonOptions.output {
        case .fold:
            guard let output = try dependencies.shellExecutor.throwingShell(command) else { return }
            await logPlain(output, level: .info, output: .screen)
        case .multiline:
            try dependencies.shellExecutor.printShell(command)
        case .quiet:
            try dependencies.shellExecutor.throwingShell(command)
        }
        dependencies.xcode.resetProjectsCache()
    }
}
