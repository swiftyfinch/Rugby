import Fish

public extension Vault {
    /// The manager to delete targets from Xcode project.
    /// - Parameter workingDirectory: A directory with Xcode project.
    func deleteTargetsManager(workingDirectory: IFolder,
                              projectPath: String) -> IDeleteTargetsManager {
        DeleteTargetsManager(logger: logger,
                             xcodeProject: xcode.project(projectPath: projectPath),
                             backupManager: backupManager(workingDirectory: workingDirectory))
    }
}
