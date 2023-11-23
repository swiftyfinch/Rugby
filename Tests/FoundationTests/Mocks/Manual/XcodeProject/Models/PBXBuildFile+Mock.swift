import XcodeProj

extension PBXBuildFile {
    static func mock(file: PBXFileElement? = nil) -> PBXBuildFile {
        PBXBuildFile(
            file: file,
            product: nil,
            settings: nil,
            platformFilter: nil,
            platformFilters: nil
        )
    }
}
