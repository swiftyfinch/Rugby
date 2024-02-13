import Foundation

// MARK: - Interface

protocol IBuildTargetsManager: AnyObject {
    func findTargets(
        _ targets: NSRegularExpression?,
        exceptTargets: NSRegularExpression?,
        includingTests: Bool
    ) async throws -> TargetsMap

    func createTarget(dependencies: TargetsMap) async throws -> IInternalTarget
}

extension IBuildTargetsManager {
    func findTargets(
        _ targets: NSRegularExpression?,
        exceptTargets: NSRegularExpression?
    ) async throws -> TargetsMap {
        try await findTargets(targets, exceptTargets: exceptTargets, includingTests: false)
    }
}

// MARK: - Implementation

final class BuildTargetsManager {
    private let xcodeProject: IInternalXcodeProject
    private let buildTargetName = "RugbyPods"

    init(xcodeProject: IInternalXcodeProject) {
        self.xcodeProject = xcodeProject
    }
}

extension BuildTargetsManager: IBuildTargetsManager {
    func findTargets(
        _ targets: NSRegularExpression?,
        exceptTargets: NSRegularExpression?,
        includingTests: Bool
    ) async throws -> TargetsMap {
        try await xcodeProject.findTargets(
            by: targets,
            except: exceptTargets,
            includingDependencies: true
        ).filter { _, target in
            guard target.isNative, !target.isPodsUmbrella else { return false }
            return includingTests || !target.isTests
        }
    }

    func createTarget(dependencies: TargetsMap) async throws -> IInternalTarget {
        try await xcodeProject.createAggregatedTarget(name: buildTargetName, dependencies: dependencies)
    }
}
