extension Collection {
    func compactMap<Wrapped>() -> [Wrapped] where Element == Wrapped? {
        compactMap { $0 }
    }
}
