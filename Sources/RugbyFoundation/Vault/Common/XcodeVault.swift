import Fish

/// The container of Xcode stuff.
public final class XcodeVault {
    private let settings: Settings
    private let logger: ILogger
    private let logsRotator: LogsRotator
    private let router: Router

    private var xcodeProjectsCache: [String: IInternalXcodeProject] = [:]

    // MARK: - Init

    init(
        settings: Settings,
        logger: ILogger,
        logsRotator: LogsRotator,
        router: Router
    ) {
        self.logger = logger
        self.logsRotator = logsRotator
        self.settings = settings
        self.router = router
    }

    // MARK: - Public Methods

    /// Returns the collection of Xcode paths relative to the working directory.
    /// - Parameter workingDirectory: A directory with Pods folder.
    public func paths(workingDirectory: IFolder) throws -> XcodeBuildPaths {
        let logsFolder = try logsRotator.currentLogFolder()
        return XcodeBuildPaths(
            project: router.paths(relativeTo: workingDirectory).podsProject,
            symroot: router.paths(relativeTo: workingDirectory).build,
            rawLog: router.paths(relativeTo: logsFolder).rawLog,
            beautifiedLog: router.paths(relativeTo: logsFolder).beautifiedLog
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
        let xcodeProject = XcodeProject(projectDataSource: projectDataSource,
                                        targetsFinder: targetsFinder,
                                        targetsEditor: targetsEditor,
                                        buildSettingsEditor: buildSettingsEditor)
        xcodeProjectsCache[projectPath] = xcodeProject
        return xcodeProject
    }
}
