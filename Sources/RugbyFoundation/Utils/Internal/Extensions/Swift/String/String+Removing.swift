extension String {
    func removing(_ count: UInt) -> String {
        guard self.count >= count else { return "" }
        var copy = self
        copy.removeFirst(Int(count))
        return copy
    }
}
