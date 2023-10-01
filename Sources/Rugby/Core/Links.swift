enum Links {
    private static let github = "github.com/swiftyfinch/Rugby"

    static let docs = "\(github)/blob/\(String.version)/Docs".cyan
    static func docs(_ subpath: String) -> String { "\(docs)/\(subpath)".cyan }

    static let commandsHelp = "\(docs)/commands-help".cyan
    static func commandsHelp(_ subpath: String) -> String { "\(commandsHelp)/\(subpath)".cyan }

    static let githubIssues = "\(github)/issues".cyan
    static let githubDiscussions = "\(github)/discussions".cyan
}
