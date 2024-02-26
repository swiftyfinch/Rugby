import Fish
import Foundation
import XcodeProj

protocol ITestplanEditor {
    func createTestplan(
        withRelativeTemplatePath relativeTemplatePath: String,
        testTargets: TargetsMap,
        inFolderPath folderPath: String
    ) throws -> URL?
}

enum TestplanEditorError: LocalizedError {
    case incorrectTestplanFormat

    var errorDescription: String? {
        switch self {
        case .incorrectTestplanFormat:
            return "Incorrect testplan format."
        }
    }
}

final class TestplanEditor {
    private typealias Error = TestplanEditorError
    private let defaultTestplanName = "Rugby"
    private let xctestplanExtension = "xctestplan"

    private let xcodeProject: IInternalXcodeProject
    private let workingDirectory: IFolder

    init(xcodeProject: IInternalXcodeProject,
         workingDirectory: IFolder) {
        self.xcodeProject = xcodeProject
        self.workingDirectory = workingDirectory
    }

    private func readTestplan(path: String) throws -> [String: Any] {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Error.incorrectTestplanFormat
        }
        return json
    }

    private func addTargets(_ targets: TargetsMap, _ json: inout [String: Any]) {
        json["testTargets"] = targets.values.map { target in
            [
                "target": [
                    "containerPath": "container:\(URL(fileURLWithPath: target.project.path).lastPathComponent)",
                    "identifier": target.uuid,
                    "name": target.name
                ]
            ]
        }
    }

    private func patchEnvironmentVariables(projectFolder: String, _ json: inout [String: Any]) {
        let environmentVariableEntries = json["environmentVariableEntries"] as? [[String: Any]]
        json["environmentVariableEntries"] = environmentVariableEntries?.compactMap { entry in
            var entry = entry
            entry["value"] = (entry["value"] as? String)?
                .replacingOccurrences(of: "$SOURCE_ROOT", with: projectFolder)
                .replacingOccurrences(of: "${SOURCE_ROOT}", with: projectFolder)
                .replacingOccurrences(of: "$(SOURCE_ROOT)", with: projectFolder)
            return entry
        }
    }

    private func patchAllEnvironmentVariables(projectPaths: [String], _ json: inout [String: Any]) {
        let defaultOptions = json["defaultOptions"] as? [String: Any]
        let targetForVariableExpansion = defaultOptions?["targetForVariableExpansion"] as? [String: Any]
        let containerPath = targetForVariableExpansion?["containerPath"] as? String

        guard let containerProject = containerPath?.components(separatedBy: ":").last,
              let projectPath = projectPaths.first(where: { $0.hasSuffix(containerProject) }) else { return }

        let projectFolder = URL(fileURLWithPath: projectPath).deletingLastPathComponent().path
        if var defaultOptions {
            patchEnvironmentVariables(projectFolder: projectFolder, &defaultOptions)
            json["defaultOptions"] = defaultOptions
        }

        let configurations = json["configurations"] as? [[String: Any]]
        json["configurations"] = configurations?.map { configuration in
            var configuration = configuration
            if var options = configuration["options"] as? [String: Any] {
                patchEnvironmentVariables(projectFolder: projectFolder, &options)
                configuration["options"] = options
            }
            return configuration
        }
    }
}

extension TestplanEditor: ITestplanEditor {
    func createTestplan(
        withRelativeTemplatePath relativeTemplatePath: String,
        testTargets: TargetsMap,
        inFolderPath folderPath: String
    ) throws -> URL? {
        let projectPaths = try xcodeProject.readWorkspaceProjectPaths()

        let templatePath = workingDirectory.subpath(relativeTemplatePath)
        var json = try readTestplan(path: templatePath)
        patchAllEnvironmentVariables(projectPaths: projectPaths, &json)
        addTargets(testTargets, &json)

        let testFolder = try Folder.create(at: folderPath)
        let testplanFileName = "\(defaultTestplanName).\(xctestplanExtension)"
        let newData = try JSONSerialization.data(withJSONObject: json as Any, options: [.prettyPrinted, .sortedKeys])
        try testFolder.createFile(named: testplanFileName, contents: String(data: newData, encoding: .utf8))

        return URL(fileURLWithPath: testFolder.subpath(testplanFileName))
    }
}
