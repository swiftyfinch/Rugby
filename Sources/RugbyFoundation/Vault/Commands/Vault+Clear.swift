import Fish

public extension Vault {
    /// The manager to clean Rugby folders.
    func cleaner() -> IСleaner {
        Сleaner(sharedBinariesPath: router.binFolderPath,
                buildFolderPath: router.buildPath)
    }
}
