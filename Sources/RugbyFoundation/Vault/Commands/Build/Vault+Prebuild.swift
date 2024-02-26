import Fish

public extension Vault {
    /// The manager to prebuild CocoaPods project.
    func prebuildManager() -> IPrebuildManager {
        let xcodeProject = xcode.project(projectPath: router.podsProjectPath)
        return PrebuildManager(
            logger: logger,
            xcodePhaseEditor: XcodePhaseEditor(),
            buildManager: internalBuildManager(),
            xcodeProject: xcodeProject,
            binariesStorage: binariesStorage,
            rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
            environmentCollector: environmentCollector
        )
    }
}
