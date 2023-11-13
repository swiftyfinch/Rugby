public extension String {
    /// Converts only the first letter of string to uppercase.
    var uppercasedFirstLetter: String {
        guard !isEmpty else { return self }
        var copy = self
        let first = copy.removeFirst()
        return "\(first.uppercased())\(copy)"
    }
}
