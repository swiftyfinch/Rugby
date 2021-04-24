import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: """

        🏈 Shake up pods project, build and throw away part of it.
        📖 \("https://github.com/swiftyfinch/Rugby".cyan) (⌘ + double click on link)
        """,
        version: "1.4.0",
        subcommands: [Cache.self, Drop.self, Clean.self, Log.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
