import Foundation

final class BuildTargetsManager {
    private let xcodeProject: XcodeProject
    private let buildTargetName = "RugbyPods"

    init(xcodeProject: XcodeProject) {
        self.xcodeProject = xcodeProject
    }

    func findTargets(_ targets: NSRegularExpression?,
                     exceptTargets: NSRegularExpression?) async throws -> Set<Target> {
        try await xcodeProject.findTargets(
            by: targets,
            except: exceptTargets,
            includingDependencies: true
        ).filter { $0.isNative && !$0.isTests && !$0.isPodsUmbrella }
    }

    func createTarget(dependencies: Set<Target>) async throws -> Target {
        try await xcodeProject.createAggregatedTarget(name: buildTargetName, dependencies: dependencies)
    }
}
