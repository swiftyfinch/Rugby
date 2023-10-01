extension Set {
    func contains(_ member: Element?) -> Bool {
        guard let member = member else { return false }
        return contains(member)
    }
}
