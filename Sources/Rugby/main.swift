import ArgumentParser

struct Rugby: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: """

        🏈 Cache CocoaPods for faster rebuild and indexing Xcode project.
        📖 \("https://github.com/swiftyfinch/Rugby".cyan) (⌘ + double click on link)
        """,
        version: "1.20.0",
        subcommands: [
            Plans.self,
            Cache.self,
            Focus.self,
            Drop.self,
            Rollback.self,
            Log.self,
            Doctor.self,
            Clean.self
        ],
        defaultSubcommand: Plans.self
    )
}

ProcessMonitor.sync()
Rugby.main()
