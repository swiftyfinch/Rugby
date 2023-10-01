import ArgumentParser
import Foundation
import RugbyFoundation

struct Plan: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "plan",
        abstract: "Run sequence of Rugby commands.",
        discussion: Links.commandsHelp("plan.md")
    )

    @Argument(help: "Name of plan to run.")
    var name: String?

    @Option(name: .shortAndLong, help: "Path to plans yaml.")
    var path: String = dependencies.router.plansRelativePath

    @Flag(name: .shortAndLong, help: "Restore projects state before the last Rugby usage.")
    var rollback = false

    @OptionGroup
    var commonOptions: CommonOptions

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.verbose)
    }
}

// MARK: - Body

extension Plan: RunnableCommand {
    func body() async throws {
        let plan = try selectPlan()
        try await run(plan: plan)
    }

    private func selectPlan() throws -> RugbyFoundation.Plan {
        if let name = name {
            return try dependencies.plansParser.named(name, path: path)
        } else {
            return try dependencies.plansParser.top(path: path)
        }
    }

    private func run(plan: RugbyFoundation.Plan) async throws {
        let commands: [RugbyFoundation.Plan.Command]
        if rollback, let commandName = Rollback.configuration.commandName {
            commands = [RugbyFoundation.Plan.Command(name: commandName)] + plan.commands
        } else {
            commands = plan.commands
        }

        let overriddenCommands = commands.map(overrideCommand)
        let runnableCommands = try overriddenCommands.map { command in
            let commandWithArgs = ([command.name.capitalized.green] + command.args).joined(separator: " ")
            return try (command.name, commandWithArgs, convertToRunnable(command))
        }
        for (commandName, commandWithArgs, runnableCommand) in runnableCommands {
            try await log(commandWithArgs, footer: commandName.capitalized.green, metricKey: commandName) {
                await dependencies.environmentCollector.logCommandDump(command: runnableCommand)
                try await runnableCommand.body()
            }
        }
    }

    private func overrideCommand(_ command: RugbyFoundation.Plan.Command) -> RugbyFoundation.Plan.Command {
        var command = command
        switch command.name {
        case Plan.configuration.commandName:
            if !command.args.contains(.pathLongKey) {
                command.args.append(contentsOf: [.pathLongKey, path])
            }
            fallthrough
        default:
            if !command.args.contains(.outputLongKey) && !command.args.contains(.outputShortKey) {
                if commonOptions.output != .fold {
                    command.args.append(contentsOf: [.outputLongKey, commonOptions.output.rawValue])
                }
            }
        }
        return command
    }

    private func convertToRunnable(_ command: RugbyFoundation.Plan.Command) throws -> RunnableCommand {
        do {
            let parsedCommand = try Rugby.parseCommand([command.name] + command.args)
            return try parsedCommand.toRunnable()
        } catch {
            Rugby.exit(withError: error)
        }
    }
}

private extension String {
    static let pathLongKey = "--path"
    static let outputLongKey = "--output"
    static let outputShortKey = "-o"
}
