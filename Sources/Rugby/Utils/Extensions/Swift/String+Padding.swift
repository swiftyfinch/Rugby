extension String {
    func padding(toSize size: Int) -> String {
        guard rawCount < size else { return self }
        let remaining = size - rawCount
        return "\(self)\(String(repeating: " ", count: remaining))"
    }
}
