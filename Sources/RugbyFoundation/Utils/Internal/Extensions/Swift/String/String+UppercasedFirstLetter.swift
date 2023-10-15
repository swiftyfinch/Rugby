extension String {
    func uppercasedFirstLetter() -> String {
        guard !isEmpty else { return self }
        var copy = self
        let first = copy.removeFirst()
        return "\(first.uppercased())\(copy)"
    }
}
