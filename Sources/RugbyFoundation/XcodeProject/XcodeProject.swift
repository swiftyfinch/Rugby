import Foundation

/// The protocol describing a service for Xcode project managment.
public protocol IXcodeProject: AnyObject {
    /// Returns paths to folders with root project and subprojects.
    func folderPaths() async throws -> [String]
    /// Returns `true` if the root project contains the key in the build settings.
    func contains(buildSettingsKey: String) async throws -> Bool
    /// Sets the value to the key in the build settings of the root project.
    func set(buildSettingsKey: String, value: Any) async throws
}

protocol IInternalXcodeProject: IXcodeProject {
    func resetCache()
    func save() async throws

    func findTargets(
        by regex: NSRegularExpression?,
        except exceptRegex: NSRegularExpression?,
        includingDependencies: Bool
    ) async throws -> TargetsMap

    func createAggregatedTarget(
        name: String,
        dependencies: TargetsMap
    ) async throws -> IInternalTarget

    func deleteTargets(
        _ targetsForRemove: TargetsMap,
        keepGroups: Bool
    ) async throws
}

// MARK: - Implementation

extension IInternalXcodeProject {
    func findTargets() async throws -> TargetsMap {
        try await findTargets(by: nil, except: nil, includingDependencies: false)
    }

    func findTargets(
        by regex: NSRegularExpression?,
        except exceptRegex: NSRegularExpression?
    ) async throws -> TargetsMap {
        try await findTargets(by: regex, except: exceptRegex, includingDependencies: false)
    }

    func deleteTargets(_ targetsForRemove: TargetsMap) async throws {
        try await deleteTargets(targetsForRemove, keepGroups: true)
    }
}

final class XcodeProject {
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

extension XcodeProject: IInternalXcodeProject {
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
                     includingDependencies: Bool = false) async throws -> TargetsMap {
        try await targetsFinder.findTargets(by: regex,
                                            except: exceptRegex,
                                            includingDependencies: includingDependencies)
    }

    // MARK: - Create Targets

    func createAggregatedTarget(name: String,
                                dependencies: TargetsMap) async throws -> IInternalTarget {
        try await targetsEditor.createAggregatedTarget(name: name, dependencies: dependencies)
    }

    // MARK: - Delete Targets

    func deleteTargets(_ targetsForRemove: TargetsMap, keepGroups: Bool = true) async throws {
        try await targetsEditor.deleteTargets(targetsForRemove, keepGroups: keepGroups)
    }
}
