import XcodeProj

// MARK: - Interface

protocol IXcodeTargetsEditor: AnyObject {
    func resetCache()
    func createAggregatedTarget(
        name: String,
        in project: IProject,
        dependencies: TargetsMap
    ) async throws -> IInternalTarget
    func deleteTargets(_ targetsForRemove: TargetsMap, keepGroups: Bool) async throws
    func addDependencies(_ dependencies: TargetsMap, to target: IInternalTarget) throws
}

// MARK: - Implementation

final class XcodeTargetsEditor: Loggable {
    let logger: ILogger

    private let projectDataSource: XcodeProjectDataSource
    private let targetsDataSource: XcodeTargetsDataSource
    private let schemesEditor: IXcodeProjectSchemesEditor

    init(logger: ILogger,
         projectDataSource: XcodeProjectDataSource,
         targetsDataSource: XcodeTargetsDataSource,
         schemesEditor: IXcodeProjectSchemesEditor) {
        self.logger = logger
        self.projectDataSource = projectDataSource
        self.targetsDataSource = targetsDataSource
        self.schemesEditor = schemesEditor
    }
}

// MARK: - IXcodeTargetsEditor

extension XcodeTargetsEditor: IXcodeTargetsEditor {
    func resetCache() {
        targetsDataSource.resetCache()
    }

    func createAggregatedTarget(
        name: String,
        in project: IProject,
        dependencies: TargetsMap
    ) async throws -> IInternalTarget {
        let pbxTarget = PBXAggregateTarget(name: name)
        pbxTarget.buildConfigurationList = try project.buildConfigurationList
        try project.pbxProject.targets.append(pbxTarget)
        project.pbxProj.add(object: pbxTarget)

        try dependencies.values.forEach { target in
            try project.pbxProj.addDependency(target, toTarget: pbxTarget)
        }

        let target = try await Target(pbxTarget: pbxTarget,
                                      project: project,
                                      explicitDependencies: dependencies,
                                      projectBuildConfigurations: project.buildConfigurations)
        targetsDataSource.addAggregatedTarget(target)
        return target
    }

    // MARK: - Delete Targets

    func deleteTargets(_ targetsForRemove: TargetsMap, keepGroups: Bool) async throws {
        guard targetsForRemove.isNotEmpty else { return }

        // Remove all dependencies with these targets
        let targets = try await targetsDataSource.targets.subtracting(targetsForRemove)
        try targets.values.forEach { target in
            // Add sub-dependencies of removing dependency explicitly
            let dependencies = target.explicitDependencies.keysIntersection(targetsForRemove)
            guard dependencies.isNotEmpty else { return }

            try dependencies.values.forEach { targetForRemove in
                let shouldBeExplicit = targetForRemove.dependencies
                    .subtracting(targetsForRemove)
                    .subtracting(target.explicitDependencies)
                if shouldBeExplicit.isNotEmpty {
                    try target.project.pbxProj.addDependencies(shouldBeExplicit, target: target)
                }
            }
            target.project.pbxProj.deleteDependencies(dependencies, target: target)
        }

        if !keepGroups {
            let targetsByProject = try targetsForRemove.values.reduce(into: [:]) { dictionary, target in
                try dictionary[target.project.uuid, default: [:]][target.uuid] = target
            }
            let targets = try await targetsDataSource.targets
            try targetsByProject.forEach { _, targetsForRemove in
                guard let project = targetsForRemove.values.first?.project else { return }
                let projectTargets = try targets.filter { try $0.value.project.uuid == project.uuid }
                project.deleteTargetGroups(targetsForRemove, targets: projectTargets)
            }
        }

        let pbxTargetsForRemove = targetsForRemove.values.lazy.map(\.pbxTarget)
        try targetsForRemove.values.forEach { target in
            try target.project.pbxProj.deleteTargetReferences(target.pbxTarget)
            try target.project.pbxProject.targets.removeAll(where: { $0.uuid == target.pbxTarget.uuid })
        }
        try await projectDataSource.rootProject.pbxProject.targets.removeAll(where: pbxTargetsForRemove.contains)

        targetsDataSource.deleteTargets(targetsForRemove)

        try await schemesEditor.deleteSchemes(ofTargets: targetsForRemove,
                                              targets: targetsDataSource.targets)
    }

    func addDependencies(_ dependencies: TargetsMap, to target: IInternalTarget) throws {
        try target.project.pbxProj.addDependencies(dependencies, target: target)
        target.addDependencies(dependencies)
        target.resetDependencies()
    }
}
