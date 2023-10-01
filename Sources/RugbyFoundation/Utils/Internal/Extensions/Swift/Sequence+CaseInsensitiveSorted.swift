extension Sequence where Element: StringProtocol {
    func caseInsensitiveSorted() -> [Element] {
        sorted { lhs, rhs in lhs.caseInsensitiveCompare(rhs) == .orderedAscending }
    }
}
