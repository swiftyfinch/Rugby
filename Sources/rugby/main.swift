import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        version: "0.0.3",
        subcommands: [Cache.self, Clean.self, Log.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
