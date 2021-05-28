import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "🏈 Shake up pods project, build and throw away part of them.",
        version: "0.0.4",
        subcommands: [Cache.self, Clean.self, Log.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
