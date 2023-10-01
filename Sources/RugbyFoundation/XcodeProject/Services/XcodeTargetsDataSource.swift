import Foundation
import XcodeProj

enum XcodeTargetsDataSourceError: LocalizedError {
    case missingTarget(String?)

    var errorDescription: String? {
        switch self {
        case let .missingTarget(target):
            return "Missing target '\(target ?? "Unknown")'."
        }
    }
}

final class XcodeTargetsDataSource {
    private typealias Error = XcodeTargetsDataSourceError
    private let dataSource: XcodeProjectDataSource
    private var cachedTargets: Set<Target>?

    var targets: Set<Target> {
        get async throws {
            if let cachedTargets = cachedTargets { return cachedTargets }
            var targets: [String: (target: PBXTarget, project: Project)] = [:]

            // Collect targets from root project
            let rootProject = try await dataSource.rootProject
            try rootProject.pbxProject.targets.forEach { target in
                targets[target.uuid] = (target, rootProject)
            }

            // Collect targets from subprojects
            let subprojects = try await dataSource.subprojects
            try subprojects.forEach { project in
                try project.pbxProject.targets.forEach { target in
                    targets[target.uuid] = (target, project)
                }
            }

            var builtTargets: [String: Target] = [:]
            for target in targets.values.map(\.target) {
                try await buildTargetsTree(target, targets: targets, builtTargets: &builtTargets)
            }
            let rugbyTargets = builtTargets.values.set()
            cachedTargets = rugbyTargets
            return rugbyTargets
        }
    }

    // MARK: - Init

    init(dataSource: XcodeProjectDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Internal

    func resetCache() {
        cachedTargets = nil
    }

    func addAggregatedTarget(_ target: Target) {
        cachedTargets?.insert(target)
        target.resetDependencies()
    }

    func deleteTargets(_ targets: Set<Target>) {
        cachedTargets?.subtract(targets)
        cachedTargets?.forEach { $0.resetDependencies() }
    }

    // MARK: - Private

    private func buildTargetsTree(_ target: PBXTarget,
                                  targets: [String: (target: PBXTarget, project: Project)],
                                  builtTargets: inout [String: Target]) async throws {
        guard builtTargets[target.uuid] == nil else { return }

        let pbxDependencies = try target.dependencies.compactMap { dependency in
            if let target = dependency.target {
                return target
            } else if case let .string(anotherProjectTargetUUID) = dependency.targetProxy?.remoteGlobalID {
                return targets[anotherProjectTargetUUID]?.target
            }
            throw Error.missingTarget(dependency.name)
        }
        for target in pbxDependencies where builtTargets[target.uuid] == nil {
            try await buildTargetsTree(target, targets: targets, builtTargets: &builtTargets)
        }

        let dependencies: Set<Target> = try await pbxDependencies.reduce(into: []) { set, dependency in
            let target: Target
            if let sharedTarget = builtTargets[dependency.uuid] {
                target = sharedTarget
            } else if let project = targets[dependency.uuid]?.project {
                target = try Target(pbxTarget: dependency,
                                    project: project,
                                    projectBuildConfigurations: await project.buildConfigurations)
            } else {
                throw Error.missingTarget(dependency.name)
            }
            set.insert(target)
        }

        guard let project = targets[target.uuid]?.project else { throw Error.missingTarget(target.name) }
        builtTargets[target.uuid] = try Target(pbxTarget: target,
                                               project: project,
                                               explicitDependencies: dependencies,
                                               projectBuildConfigurations: await project.buildConfigurations)
    }
}
