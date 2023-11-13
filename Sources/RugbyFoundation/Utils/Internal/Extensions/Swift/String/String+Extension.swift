extension String {
    func excludingExtension() -> String {
        guard let lastIndex = lastIndex(of: ".") else { return self }
        return String(self[startIndex ..< lastIndex])
    }
}
