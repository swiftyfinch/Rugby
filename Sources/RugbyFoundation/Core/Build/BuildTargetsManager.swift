import Foundation

final class BuildTargetsManager {
    private let xcodeProject: XcodeProject
    private let buildTargetName = "RugbyPods"

    init(xcodeProject: XcodeProject) {
        self.xcodeProject = xcodeProject
    }

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
