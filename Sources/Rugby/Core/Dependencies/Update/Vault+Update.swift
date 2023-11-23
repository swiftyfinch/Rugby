import RugbyFoundation

extension Vault {
    var rugbyUpdater: GitHubUpdater {
        let paths = GitHubUpdaterPaths(
            downloadsPath: router.downloadsCLTFolderPath,
            cltFolderPath: router.cltFolderPath,
            cltName: router.cltName,
            repositoryPath: router.repositoryPath
        )
        return GitHubUpdater(
            logger: logger,
            releaseListLoader: GitHubReleaseListLoader(paths: paths),
            binaryInstaller: GitHubBinaryInstaller(paths: paths,
                                                   logger: logger,
                                                   shellExecutor: shellExecutor),
            versionParser: VersionParser(),
            shellExecutor: shellExecutor
        )
    }
}

extension Settings {
    var minUpdateVersion: String { "2.0.0b2" }
}

private extension IRouter {
    var cltName: String { "rugby" }
    var cltFolderPath: String { "\(rugbySharedFolderPath)/clt" }
    var repositoryPath: String { "swiftyfinch/rugby" }
    var downloadsCLTFolderPath: String { "\(cltFolderPath)/downloads" }
}
