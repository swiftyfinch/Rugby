import Fish

public extension Vault {
    /// The manager to clean Rugby folders.
    /// - Parameter workingDirectory: A directory with Pods folder.
    func cleaner(workingDirectory: IFolder) -> IСleaner {
        Сleaner(sharedBinariesPath: router.paths.binFolder,
                buildFolderPath: router.paths(relativeTo: workingDirectory).build)
    }
}
