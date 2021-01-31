import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        subcommands: [Cache.self, Clean.self, Log.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
