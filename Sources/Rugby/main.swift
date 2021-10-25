import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: """

        🏈 Shake up pods project, build and throw away part of it.
        📖 \("https://github.com/swiftyfinch/Rugby".cyan) (⌘ + double click on link)
        """,
        version: "1.12.1",
        subcommands: [
            Plans.self,
            Cache.self,
            Focus.self,
            Drop.self,
            Log.self,
            Doctor.self,
            Clean.self
        ],
        defaultSubcommand: Plans.self
    )
}
Rugby.main()
