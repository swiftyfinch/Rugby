import Foundation
import XcodeProj

final class XcodeProjectDataSource: Loggable {
    let logger: ILogger

    let projectPath: String
    private var cachedRootProject: IProject?
    private var cachedSubprojects: [IProject]?

    var rootProject: IProject {
        get async throws {
            if let cachedRootProject { return cachedRootProject }
            let project = try await log("Reading Project", auto: Project(path: .string(projectPath)))
            cachedRootProject = project
            return project
        }
    }

    var subprojects: [IProject] {
        get async throws {
            if let cachedSubprojects { return cachedSubprojects }

            let subprojects: [IProject]
            let xcodeprojFileReferences = try await rootProject.pbxProj.projectReferences()
            if xcodeprojFileReferences.isNotEmpty {
                subprojects = try await log("Reading Subprojects", block: {
                    try await xcodeprojFileReferences.concurrentMap { reference in
                        try Project(path: .reference(reference))
                    }
                })
            } else {
                subprojects = []
            }
            cachedSubprojects = subprojects
            return subprojects
        }
    }

    init(logger: ILogger, projectPath: String) {
        self.logger = logger
        self.projectPath = projectPath
    }

    func resetCache() {
        cachedRootProject = nil
        cachedSubprojects = nil
    }

    func save() async throws {
        // Save only read projects
        var projects = cachedSubprojects ?? []
        cachedRootProject.flatMap { projects.append($0) }

        try await projects.concurrentMap { project in
            try project.xcodeProj.write(pathString: project.path, override: true)
        }
    }
}
