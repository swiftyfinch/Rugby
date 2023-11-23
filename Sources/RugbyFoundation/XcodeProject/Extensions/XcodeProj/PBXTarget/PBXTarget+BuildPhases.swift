import XcodeProj

extension PBXTarget {
    func constructBuildPhases() -> [BuildPhase] {
        buildPhases.compactMap(BuildPhase.init)
    }
}
