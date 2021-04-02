import ArgumentParser

extension ParsableCommand {
    // swiftlint:disable:next identifier_name
    static var _errorLabel: String {
        "⛔️ \u{1B}[31mError"
    }
}

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: """
        \("🏈 Cache some pods: build and throw away part of them.".green)
        📖 https://github.com/swiftyfinch/Rugby (⌘ + double click)
        """,
        version: "1.2.0",
        subcommands: [Cache.self, Drop.self, Clean.self, Log.self],
        defaultSubcommand: Cache.self
    )
}
Rugby.main()
