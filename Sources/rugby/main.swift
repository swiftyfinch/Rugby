import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "🏈 Cache some pods: build and throw away part of them.".green,
        version: "0.0.6",
        subcommands: [Cache.self, Clean.self, Log.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
