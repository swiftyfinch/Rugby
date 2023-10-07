import Foundation

final class BuildTargetsManager {
    private let xcodeProject: XcodeProject
    private let buildTargetName = "RugbyPods"

    init(xcodeProject: XcodeProject) {
        self.xcodeProject = xcodeProject
    }

    func findTargets(_ targets: NSRegularExpression?,
                     exceptTargets: NSRegularExpression?) async throws -> [String: IInternalTarget] {
        try await xcodeProject.findTargets(
            by: targets,
            except: exceptTargets,
            includingDependencies: true
        ).filter { _, target in
            target.isNative && !target.isTests && !target.isPodsUmbrella
        }
    }

    func createTarget(dependencies: [String: IInternalTarget]) async throws -> IInternalTarget {
        try await xcodeProject.createAggregatedTarget(name: buildTargetName, dependencies: dependencies)
    }
}
