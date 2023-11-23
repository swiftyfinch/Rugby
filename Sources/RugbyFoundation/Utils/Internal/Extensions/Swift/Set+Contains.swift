extension Set {
    func contains(_ member: Element?) -> Bool {
        guard let member else { return false }
        return contains(member)
    }
}
