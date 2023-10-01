import ArgumentParser
import Fish
import Foundation

struct Clear: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "clear",
        abstract: "Clear modules cache.",
        discussion: Links.commandsHelp("clear.md"),
        subcommands: [Clear.Build.self, Clear.Shared.self]
    )

    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "List of modules for deletion.")
    var modules: [String] = []

    @OptionGroup
    var commonOptions: CommonOptions

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.verbose,
                      muteSound: true)
    }
}

// MARK: - Body

extension Clear: RunnableCommand {
    func body() async throws {
        let cleaner = dependencies.cleaner(workingDirectory: Folder.current)
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                if modules.isEmpty {
                    try await cleaner.deleteAllSharedBinaries()
                } else {
                    try await cleaner.deleteSharedBinaries(names: modules)
                }
            }
            group.addTask { try await cleaner.deleteBuildFolder() }
            try await group.waitForAll()
        }
    }
}

// MARK: - Build Subcommand

extension Clear {
    private struct Build: RunnableCommand {
        static var configuration = CommandConfiguration(
            commandName: "build",
            abstract: "Delete .rugby/build folder.",
            discussion: Links.commandsHelp("clear/build.md")
        )

        @OptionGroup
        var commonOptions: CommonOptions

        func run() async throws {
            try await run(body,
                          outputType: commonOptions.output,
                          logLevel: commonOptions.verbose,
                          muteSound: true)
        }

        func body() async throws {
            let cleaner = dependencies.cleaner(workingDirectory: Folder.current)
            try await cleaner.deleteBuildFolder()
        }
    }
}

// MARK: - Shared Subcommand

extension Clear {
    private struct Shared: RunnableCommand {
        static var configuration = CommandConfiguration(
            commandName: "shared",
            abstract: "Delete .rugby/bin folder.",
            discussion: Links.commandsHelp("clear/shared.md")
        )

        @OptionGroup
        var commonOptions: CommonOptions

        func run() async throws {
            try await run(body,
                          outputType: commonOptions.output,
                          logLevel: commonOptions.verbose,
                          muteSound: true)
        }

        func body() async throws {
            let cleaner = dependencies.cleaner(workingDirectory: Folder.current)
            try await cleaner.deleteAllSharedBinaries()
        }
    }
}
