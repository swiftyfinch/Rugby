extension String {
    func subpath(_ pathComponents: String?...) -> String {
        ([self] + pathComponents.compactMap()).joined(separator: "/")
    }
}
