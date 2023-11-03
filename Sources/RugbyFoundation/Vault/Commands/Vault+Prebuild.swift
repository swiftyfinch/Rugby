import Fish

public extension Vault {
    /// The manager to prebuild CocoaPods project.
    /// - Parameter workingDirectory: A directory with Pods folder.
    func prebuildManager(workingDirectory: IFolder) -> IPrebuildManager {
        PrebuildManager(
            logger: logger,
            xcodePhaseEditor: XcodePhaseEditor(),
            buildManager: internalBuildManager(workingDirectory: workingDirectory)
        )
    }
}
