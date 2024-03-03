import Fish
import Foundation
import XcodeProj

// MARK: - Interface

protocol ITestplanEditor {
    func expandTestplanPath(_ path: String) throws -> String

    func createTestplan(
        testplanTemplatePath: String,
        testTargets: TargetsMap,
        inFolderPath folderPath: String
    ) throws -> URL
}

enum TestplanEditorError: LocalizedError {
    case incorrectTestplanPath(String)
    case incorrectTestplanFormat

    var errorDescription: String? {
        switch self {
        case let .incorrectTestplanPath(path):
            return "Incorrect testplan path: \(path)"
        case .incorrectTestplanFormat:
            return "Incorrect testplan format."
        }
    }
}

// MARK: - Implementation

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
        guard let testTargetsJSON = json["testTargets"] as? [[String: Any]] else { return }
        let testTargets = testTargetsJSON.reduce(into: [:]) { targets, json in
            guard let name = (json["target"] as? [String: String])?["name"] else { return }
            targets[name] = (json["parallelizable"] as? Int == 1)
        }
        json["testTargets"] = targets.values.map { target in
            [
                "target": [
                    "containerPath": "container:\(URL(fileURLWithPath: target.project.path).lastPathComponent)",
                    "identifier": target.uuid,
                    "name": target.name
                ],
                "parallelizable": testTargets[target.name] ?? false
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
    func expandTestplanPath(_ path: String) throws -> String {
        let resolvedPath = NSString(string: path).expandingTildeInPath
        let pathURL = URL(fileURLWithPath: resolvedPath)
        if File.isExist(at: pathURL.path) {
            return pathURL.path
        } else if pathURL.pathExtension.isEmpty {
            let pathWithExtension = pathURL.appendingPathExtension("xctestplan")
            if File.isExist(at: pathWithExtension.path) {
                return pathWithExtension.path
            }
        }
        throw Error.incorrectTestplanPath(pathURL.path)
    }

    func createTestplan(
        testplanTemplatePath: String,
        testTargets: TargetsMap,
        inFolderPath folderPath: String
    ) throws -> URL {
        let projectPaths = try xcodeProject.readWorkspaceProjectPaths()

        var json = try readTestplan(path: testplanTemplatePath)
        patchAllEnvironmentVariables(projectPaths: projectPaths, &json)
        addTargets(testTargets, &json)

        let testFolder = try Folder.create(at: folderPath)
        let testplanFileName = "\(defaultTestplanName).\(xctestplanExtension)"
        let newData = try JSONSerialization.data(withJSONObject: json as Any, options: [.prettyPrinted, .sortedKeys])
        try testFolder.createFile(named: testplanFileName, contents: String(data: newData, encoding: .utf8))

        return URL(fileURLWithPath: testFolder.subpath(testplanFileName))
    }
}
