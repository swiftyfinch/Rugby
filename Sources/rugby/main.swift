import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: """
        \("🏈 Cache some pods: build and throw away part of them.".green)
        📖 https://github.com/swiftyfinch/Rugby (⌘ + double click)
        """,
        version: "1.4.0",
        subcommands: [Cache.self, Drop.self, Clean.self, Log.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
