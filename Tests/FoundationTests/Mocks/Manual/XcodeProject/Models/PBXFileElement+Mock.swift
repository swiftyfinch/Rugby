import XcodeProj

extension PBXFileElement {
    static func mock(
        name: String? = nil,
        path: String? = nil,
        parent: PBXGroup? = nil
    ) -> PBXFileElement {
        let mock = PBXFileElement(
            sourceTree: .group,
            path: path,
            name: name,
            includeInIndex: true
        )
        mock.parent = parent
        return mock
    }
}
