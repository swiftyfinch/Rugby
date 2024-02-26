import Fish
import Foundation
import XcodeProj

protocol IXcodeProjectSchemesEditor {
    func deleteSchemes(
        ofTargets targetsForRemove: TargetsMap,
        targets: TargetsMap
    ) async throws

    func createTestingScheme(
        _ target: IInternalTarget,
        buildConfiguration: String,
        testplanPath: String
    )
}

final class XcodeProjectSchemesEditor: Loggable {
    let logger: ILogger
    private let dataSource: XcodeProjectDataSource

    init(logger: ILogger,
         dataSource: XcodeProjectDataSource) {
        self.logger = logger
        self.dataSource = dataSource
    }

    private func deleteSchemes(ofTargets targetsForRemove: TargetsMap,
                               targets: TargetsMap,
                               project: IProject) async throws {
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

    private func findBrokenSchemes(
        _ schemes: Set<Scheme>,
        ofTargets targets: TargetsMap
    ) throws -> Set<Scheme> {
        let references = targets.values.map(\.uuid).set()
        return schemes.filter { !$0.isReachable(fromReferences: references) }
    }

    private func findSchemes(
        _ schemes: Set<Scheme>,
        byTargets targets: TargetsMap
    ) throws -> Set<Scheme> {
        let targetNames = targets.values.map(\.name).set()
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

extension XcodeProjectSchemesEditor: IXcodeProjectSchemesEditor {
    func deleteSchemes(
        ofTargets targetsForRemove: TargetsMap,
        targets: TargetsMap
    ) async throws {
        try await deleteSchemes(ofTargets: targetsForRemove,
                                targets: targets,
                                project: dataSource.rootProject)

        for project in try await dataSource.subprojects {
            try await deleteSchemes(ofTargets: targetsForRemove,
                                    targets: targets,
                                    project: project)
        }
    }

    func createTestingScheme(
        _ target: IInternalTarget,
        buildConfiguration: String,
        testplanPath: String
    ) {
        let projectLastPathComponent = URL(fileURLWithPath: target.project.path).lastPathComponent
        let buildAction = XCScheme.BuildAction(
            buildActionEntries: [
                XCScheme.BuildAction.Entry(
                    buildableReference: XCScheme.BuildableReference(
                        referencedContainer: "container:\(projectLastPathComponent)",
                        blueprintIdentifier: target.pbxTarget.uuid,
                        buildableName: target.name,
                        blueprintName: target.name
                    ),
                    buildFor: [.testing]
                )
            ],
            parallelizeBuild: true,
            buildImplicitDependencies: true
        )
        let testAction = XCScheme.TestAction(buildConfiguration: buildConfiguration, macroExpansion: nil)
        testAction.testPlans = [XCScheme.TestPlanReference(reference: "container:\(testplanPath)", default: true)]
        let scheme = XCScheme(
            name: target.name,
            lastUpgradeVersion: nil,
            version: nil,
            buildAction: buildAction,
            testAction: testAction
        )
        for userData in target.project.xcodeProj.userData {
            userData.schemes.append(scheme)
        }
    }
}
