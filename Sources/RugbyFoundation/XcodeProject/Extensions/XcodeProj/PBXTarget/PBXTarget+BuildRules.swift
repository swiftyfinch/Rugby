import XcodeProj

extension PBXTarget {
    func constructBuildRules() -> [BuildRule] {
        buildRules.map(BuildRule.init)
    }
}
