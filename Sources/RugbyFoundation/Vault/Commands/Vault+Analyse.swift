import Fish
import Foundation

public extension Vault {
    func analyseManager() -> IAnalyseManager {
        let xcodeProject = xcode.project(projectPath: router.podsProjectPath)
        let buildTargetsManager = BuildTargetsManager(xcodeProject: xcodeProject)
        return AnalyseManager(logger: logger,
                              rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
                              buildTargetsManager: buildTargetsManager,
                              binariesManager: binariesManager,
                              targetsHasher: targetsHasher())
    }
}
