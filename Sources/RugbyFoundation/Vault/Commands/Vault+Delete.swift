import Fish

public extension Vault {
    /// The manager to delete targets from Xcode project.
    func deleteTargetsManager(projectPath: String) -> IDeleteTargetsManager {
        DeleteTargetsManager(logger: logger,
                             xcodeProject: xcode.project(projectPath: projectPath),
                             backupManager: backupManager())
    }
}
