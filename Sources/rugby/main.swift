import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "🏈 Cache some pods: build and throw away part of them.".green,
        version: "1.0.0",
        subcommands: [Cache.self, Drop.self, Clean.self, Log.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
