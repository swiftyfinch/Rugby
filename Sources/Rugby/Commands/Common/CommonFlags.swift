enum CommonFlags {
    static let version = "--version"
    static let help: Set = ["-h", "--help"]
    static let all = help.union([version])
}
