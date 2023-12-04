import Foundation

// MARK: - Interface

protocol IBuildTargetsManager: AnyObject {
    func findTargets(
        _ targets: NSRegularExpression?,
        exceptTargets: NSRegularExpression?
    ) async throws -> TargetsMap

    func createTarget(dependencies: TargetsMap) async throws -> IInternalTarget
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
    func findTargets(_ targets: NSRegularExpression?,
                     exceptTargets: NSRegularExpression?) async throws -> TargetsMap {
        try await xcodeProject.findTargets(
            by: targets,
            except: exceptTargets,
            includingDependencies: true
        ).filter { _, target in
            target.isNative && !target.isTests && !target.isPodsUmbrella
        }
    }

    func createTarget(dependencies: TargetsMap) async throws -> IInternalTarget {
        try await xcodeProject.createAggregatedTarget(name: buildTargetName, dependencies: dependencies)
    }
}
