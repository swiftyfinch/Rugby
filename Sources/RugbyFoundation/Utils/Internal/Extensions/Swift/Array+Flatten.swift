extension Array where Element: Any {
    func flatten() -> [Any] {
        flatMap { element -> [Any] in
            if let anyarray = element as? [Any] {
                return anyarray.map { $0 as Any }.flatten()
            }
            return [element]
        }
    }
}
