extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}

extension Optional where Wrapped: Collection {
    var isNotEmpty: Bool {
        map(\.isNotEmpty) ?? false
    }
}
