import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        subcommands: [Cache.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
