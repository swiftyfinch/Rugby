import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        subcommands: [Cache.self, Clean.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
