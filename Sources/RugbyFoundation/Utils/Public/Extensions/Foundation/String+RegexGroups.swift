public extension String {
    /// Returns RegEx capture groups matches.
    func groups(regex: String) throws -> [String] {
        try groups(regex.regex())
    }
}
