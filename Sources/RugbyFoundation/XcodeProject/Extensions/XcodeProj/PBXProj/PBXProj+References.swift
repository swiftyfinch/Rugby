import XcodeProj

extension PBXProj {
    func projectReferences() -> [PBXFileReference] {
        fileReferences.filter { $0.path?.hasSuffix(".xcodeproj") == true }
    }
}
