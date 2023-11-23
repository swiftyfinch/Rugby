import XcodeProj

extension PBXVariantGroup {
    static func mock(
        children: [PBXFileElement],
        name: String? = nil,
        path: String? = nil,
        parent: PBXGroup? = nil
    ) -> PBXVariantGroup {
        let mock = PBXVariantGroup(
            children: children,
            sourceTree: .group,
            name: name,
            path: path
        )
        mock.parent = parent
        return mock
    }
}
