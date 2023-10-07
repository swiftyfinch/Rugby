import Foundation

/// The service for Xcode project managment.
public final class XcodeProject {
    private let projectDataSource: XcodeProjectDataSource
    private let targetsFinder: XcodeTargetsFinder
    private let targetsEditor: XcodeTargetsEditor
    private let buildSettingsEditor: XcodeBuildSettingsEditor

    init(projectDataSource: XcodeProjectDataSource,
         targetsFinder: XcodeTargetsFinder,
         targetsEditor: XcodeTargetsEditor,
         buildSettingsEditor: XcodeBuildSettingsEditor) {
        self.projectDataSource = projectDataSource
        self.targetsFinder = targetsFinder
        self.targetsEditor = targetsEditor
        self.buildSettingsEditor = buildSettingsEditor
    }
}

// MARK: - Implementation

extension XcodeProject {
    // MARK: - File System

    func folderPaths() async throws -> [String] {
        let subprojectsPaths = try await projectDataSource.subprojects.map(\.path)
        return [projectDataSource.projectPath] + subprojectsPaths
    }

    func resetCache() {
        projectDataSource.resetCache()
        targetsEditor.resetCache()
    }

    func save() async throws {
        try await projectDataSource.save()
    }

    // MARK: - Build Settings

    func contains(buildSettingsKey: String) async throws -> Bool {
        try await buildSettingsEditor.contains(buildSettingsKey: buildSettingsKey)
    }

    func set(buildSettingsKey: String, value: Any) async throws {
        try await buildSettingsEditor.set(buildSettingsKey: buildSettingsKey, value: value)
    }

    // MARK: - Find Targets

    func findTargets(by regex: NSRegularExpression? = nil,
                     except exceptRegex: NSRegularExpression? = nil,
                     includingDependencies: Bool = false) async throws -> [String: Target] {
        try await targetsFinder.findTargets(by: regex,
                                            except: exceptRegex,
                                            includingDependencies: includingDependencies)
    }

    // MARK: - Create Targets

    func createAggregatedTarget(name: String,
                                dependencies: [String: Target]) async throws -> Target {
        try await targetsEditor.createAggregatedTarget(name: name, dependencies: dependencies)
    }

    // MARK: - Delete Targets

    func deleteTargets(_ targetsForRemove: [String: Target], keepGroups: Bool = true) async throws {
        try await targetsEditor.deleteTargets(targetsForRemove, keepGroups: keepGroups)
    }
}
