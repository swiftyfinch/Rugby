import Fish
import XcodeProj

final class XcodeProjectSchemesEditor: Loggable {
    let logger: ILogger
    private let dataSource: XcodeProjectDataSource

    init(logger: ILogger,
         dataSource: XcodeProjectDataSource) {
        self.logger = logger
        self.dataSource = dataSource
    }

    func deleteSchemes(ofTargets targetsForRemove: Set<Target>, targets: Set<Target>) async throws {
        try await deleteSchemes(ofTargets: targetsForRemove,
                                targets: targets,
                                project: dataSource.rootProject)

        for project in try await dataSource.subprojects {
            try await deleteSchemes(ofTargets: targetsForRemove,
                                    targets: targets,
                                    project: project)
        }
    }

    private func deleteSchemes(ofTargets targetsForRemove: Set<Target>,
                               targets: Set<Target>,
                               project: Project) async throws {
        let schemes = try await findSchemes(projectPath: project.path)
        let brokenSchemes = try findBrokenSchemes(schemes, ofTargets: targets)
        let schemesByTargets = try findSchemes(schemes, byTargets: targetsForRemove)
        try await deleteSchemes(brokenSchemes.union(schemesByTargets), project: project.xcodeProj)
    }

    private func findSchemes(projectPath: String) async throws -> Set<Scheme> {
        let files = try Folder.at(projectPath).files(deep: true).filter { $0.pathExtension == "xcscheme" }
        let schemes = try await files.concurrentCompactMap { file in
            try Scheme(path: file.path)
        }
        return schemes.set()
    }

    private func findBrokenSchemes(_ schemes: Set<Scheme>, ofTargets targets: Set<Target>) throws -> Set<Scheme> {
        let references = targets.map(\.uuid)
        return schemes.filter { !$0.isReachable(fromReferences: references) }
    }

    private func findSchemes(_ schemes: Set<Scheme>, byTargets targets: Set<Target>) throws -> Set<Scheme> {
        let targetNames = targets.map(\.name)
        return schemes.filter { targetNames.contains($0.name) }
    }

    private func deleteSchemes(_ schemes: Set<Scheme>, project: XcodeProj) async throws {
        try await schemes.concurrentForEach { scheme in
            try File.delete(at: scheme.path)
        }

        let schemesNames = schemes.map(\.name)
        project.sharedData?.schemes.removeAll { schemesNames.contains($0.name) }
        for userData in project.userData {
            userData.schemes.removeAll { schemesNames.contains($0.name) }
        }
    }
}
