import Foundation
import XcodeProj

final class XcodeProjectDataSource: Loggable {
    let logger: ILogger

    let projectPath: String
    private var cachedRootProject: Project?
    private var cachedSubprojects: [Project]?

    var rootProject: Project {
        get async throws {
            if let cachedRootProject { return cachedRootProject }
            let project = try await log("Reading Project", level: .info, auto: Project(path: .string(projectPath)))
            cachedRootProject = project
            return project
        }
    }

    var subprojects: [Project] {
        get async throws {
            if let cachedSubprojects { return cachedSubprojects }

            let subprojects: [Project]
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
        cachedRootProject.map { projects.append($0) }

        try await projects.concurrentMap { project in
            try project.xcodeProj.write(pathString: project.path, override: true)
        }
    }
}
