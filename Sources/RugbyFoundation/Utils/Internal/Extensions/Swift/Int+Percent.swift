extension Int {
    func percent(total: Int) -> Int {
        guard total != 0 else { return 0 }
        return Int(Double(self) / Double(total) * 100)
    }
}
