extension Collection where Element: Hashable {
    func set() -> Set<Element> {
        Set(self)
    }
}
