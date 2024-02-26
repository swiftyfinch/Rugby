import Fish

/// The container of Xcode stuff.
public final class XcodeVault {
    private let settings: Settings
    private let logger: ILogger
    private let logsRotator: LogsRotator
    private let router: IRouter

    private var xcodeProjectsCache: [String: IInternalXcodeProject] = [:]

    // MARK: - Init

    init(
        settings: Settings,
        logger: ILogger,
        logsRotator: LogsRotator,
        router: IRouter
    ) {
        self.logger = logger
        self.logsRotator = logsRotator
        self.settings = settings
        self.router = router
    }

    // MARK: - Public Methods

    /// Returns the collection of Xcode paths relative to the working directory.
    /// - Parameter logsSubfolder: An intermediate folder to keep specific logs.
    public func paths(logsSubfolder: String? = nil) throws -> XcodeBuildPaths {
        let logsFolder = try logsRotator.currentLogFolder().name
        let logsSubpath = logsSubfolder.map { logsFolder.subpath($0) } ?? logsFolder
        return XcodeBuildPaths(
            project: router.podsProjectPath,
            symroot: router.buildPath,
            rawLog: router.rawLogPath(subpath: logsSubpath),
            beautifiedLog: router.beautifiedLog(subpath: logsSubpath)
        )
    }

    /// Reset the Xcode projects cache.
    public func resetProjectsCache() {
        xcodeProjectsCache.removeAll()
    }

    // MARK: - Internal Methods

    func project(projectPath: String) -> IInternalXcodeProject {
        if let cachedXcodeProject = xcodeProjectsCache[projectPath] { return cachedXcodeProject }

        let projectDataSource = XcodeProjectDataSource(logger: logger, projectPath: projectPath)
        let schemesEditor = XcodeProjectSchemesEditor(logger: logger, dataSource: projectDataSource)
        let targetsDataSource = XcodeTargetsDataSource(dataSource: projectDataSource)
        let targetsFinder = XcodeTargetsFinder(targetsDataSource: targetsDataSource)
        let targetsEditor = XcodeTargetsEditor(logger: logger,
                                               projectDataSource: projectDataSource,
                                               targetsDataSource: targetsDataSource,
                                               schemesEditor: schemesEditor)
        let buildSettingsEditor = XcodeBuildSettingsEditor(projectDataSource: projectDataSource)
        let xcodeWorkspaceEditor = XcodeWorkspaceEditor(workingDirectory: router.workingDirectory)
        let xcodeProject = XcodeProject(projectDataSource: projectDataSource,
                                        targetsFinder: targetsFinder,
                                        targetsEditor: targetsEditor,
                                        buildSettingsEditor: buildSettingsEditor,
                                        schemesEditor: schemesEditor,
                                        workspaceEditor: xcodeWorkspaceEditor)
        xcodeProjectsCache[projectPath] = xcodeProject
        return xcodeProject
    }
}
