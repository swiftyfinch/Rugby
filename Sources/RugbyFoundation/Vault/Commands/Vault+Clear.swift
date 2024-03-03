import Fish

public extension Vault {
    /// The manager to clean Rugby folders.
    func cleaner() -> ICleaner {
        Cleaner(sharedBinariesPath: router.binFolderPath,
                buildFolderPath: router.buildPath,
                testsFolderPath: router.testsImpactFolderPath)
    }
}
