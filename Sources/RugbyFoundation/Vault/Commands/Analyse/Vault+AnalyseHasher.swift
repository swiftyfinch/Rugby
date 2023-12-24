import Fish
import Foundation

public extension Vault {
    /// The manager to analyse the hash of targets.
    func analyseHasherManager() -> IAnalyseHasherManager {
        let xcodeProject = xcode.project(projectPath: router.podsProjectPath)
        let buildTargetsManager = BuildTargetsManager(xcodeProject: xcodeProject)
        return AnalyseHasherManager(logger: logger,
                                    rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
                                    buildTargetsManager: buildTargetsManager,
                                    binariesManager: binariesManager,
                                    targetsHasher: targetsHasher())
    }
}
