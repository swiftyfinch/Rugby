import ArgumentParser

struct Doctor: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "doctor",
        abstract: "Heal your wounds after using Rugby (or not).",
        discussion: Links.commandsHelp("doctor.md")
    )

    func run() async throws {
        let lastLogsPath = (try? dependencies.logsRotator.previousLogFolder())?
            .path.homeFinderRelativePath() ?? "~/.rugby/logs"

        print("""
        🚑 If you have any problems, please try these solutions.
        After each one, you need to repeat your usual workflow.
        \("(⌘ + double click on the url)".yellow) to open it in a browser.

        1. Update 🏈 Rugby to the latest version: \("rugby update".yellow)
           \(Links.commandsHelp("update.md"))
        2. Check that you're building the proper configuration.
           Sometimes projects don't have the default \("Debug".yellow) config.
           \("rugby cache --config Your-Not-Debug-Config".yellow)
           \(Links.commandsHelp("shortcuts/cache.md"))
        3. Add ignore option: \("rugby cache --ignore-cache".yellow).
           Be careful, you can't pass this option to plan command this way.
           \(Links.commandsHelp("shortcuts/cache.md"))
        4. Try \("rugby clear".yellow) before repeating your usual workflow.
           \(Links.commandsHelp("clear.md"))
        5. Try to clean up your \("DerivedData".yellow) and use \("rugby clear".yellow) together.
        6. Check that the Pods project builds successfully without 🏈 Rugby.

        By the way, you can try to investigate building logs by yourself.
        \("Last ones saved in folder: \(lastLogsPath.yellow)")

        Open an issue/discussion on GitHub or by any convenient support channel.
        Attach the last logs, but be sure that there are \("no sensitive".red) data.
        \(Links.githubIssues)
        \(Links.githubDiscussions)
        """)
    }
}
