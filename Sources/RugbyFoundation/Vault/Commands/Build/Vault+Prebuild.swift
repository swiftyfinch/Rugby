import Fish

public extension Vault {
    /// The manager to prebuild CocoaPods project.
    func prebuildManager() -> IPrebuildManager {
        PrebuildManager(
            logger: logger,
            xcodePhaseEditor: XcodePhaseEditor(),
            buildManager: internalBuildManager(),
            xcodeProject: xcode.project(projectPath: router.podsProjectPath),
            binariesManager: binariesManager
        )
    }
}
