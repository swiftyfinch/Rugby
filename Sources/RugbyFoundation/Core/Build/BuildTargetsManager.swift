import Foundation

// MARK: - Interface

protocol IBuildTargetsManager: AnyObject {
    func findTargets(
        _ targets: NSRegularExpression?,
        exceptTargets: NSRegularExpression?,
        includingTests: Bool
    ) async throws -> TargetsMap

    func filterTargets(
        _ targets: TargetsMap,
        includingTests: Bool
    ) -> TargetsMap

    func createTarget(dependencies: TargetsMap) async throws -> IInternalTarget
}

extension IBuildTargetsManager {
    func findTargets(
        _ targets: NSRegularExpression?,
        exceptTargets: NSRegularExpression?
    ) async throws -> TargetsMap {
        try await findTargets(targets, exceptTargets: exceptTargets, includingTests: false)
    }

    func filterTargets(_ targets: TargetsMap) -> TargetsMap {
        filterTargets(targets, includingTests: false)
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
        let foundTargets = try await xcodeProject.findTargets(
            by: targets,
            except: exceptTargets,
            includingDependencies: true
        )
        return filterTargets(foundTargets, includingTests: includingTests)
    }

    func filterTargets(_ targets: TargetsMap, includingTests: Bool) -> TargetsMap {
        targets.filter { _, target in
            guard target.isNative, !target.isPodsUmbrella, !target.isApplication else { return false }
            return includingTests || !target.isTests
        }
    }

    func createTarget(dependencies: TargetsMap) async throws -> IInternalTarget {
        try await xcodeProject.createAggregatedTarget(name: buildTargetName, dependencies: dependencies)
    }
}
