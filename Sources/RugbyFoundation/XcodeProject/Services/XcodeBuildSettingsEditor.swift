final class XcodeBuildSettingsEditor {
    private let projectDataSource: XcodeProjectDataSource

    init(projectDataSource: XcodeProjectDataSource) {
        self.projectDataSource = projectDataSource
    }

    func contains(buildSettingsKey: String) async throws -> Bool {
        let buildConfigurationList = try await projectDataSource.rootProject.buildConfigurationList
        return buildConfigurationList.buildConfigurations.contains {
            $0.buildSettings[buildSettingsKey] != nil
        }
    }

    func set(buildSettingsKey: String, value: Any) async throws {
        let buildConfigurationList = try await projectDataSource.rootProject.buildConfigurationList
        buildConfigurationList.buildConfigurations.forEach {
            $0.buildSettings[buildSettingsKey] = value
        }
    }
}
