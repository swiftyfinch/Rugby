extension String {
    func prefixCount(symbols: Character = " ") -> UInt {
        UInt(prefix(while: { $0 == symbols }).count)
    }
}
