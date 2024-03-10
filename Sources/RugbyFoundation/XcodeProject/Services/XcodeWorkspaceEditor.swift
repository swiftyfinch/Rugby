import Fish
import XcodeProj

// MARK: - Interface

protocol IXcodeWorkspaceEditor: AnyObject {
    func readProjectPaths() throws -> [String]
}

// MARK: - Implementation

final class XcodeWorkspaceEditor {
    private let workingDirectory: IFolder

    private let xcworkspaceExtension = "xcworkspace"
    private let xcodeprojExtension = "xcodeproj"

    init(workingDirectory: IFolder) {
        self.workingDirectory = workingDirectory
    }

    private func findWorkspace(in folder: IFolder) throws -> XCWorkspace? {
        let xcworkspacePaths = try folder.folders().map(\.path).filter { $0.hasSuffix(xcworkspaceExtension) }
        guard let xcworkspacePath = xcworkspacePaths.first else { return nil }
        return try XCWorkspace(pathString: xcworkspacePath)
    }
}

// MARK: - IXcodeWorkspaceEditor

extension XcodeWorkspaceEditor: IXcodeWorkspaceEditor {
    func readProjectPaths() throws -> [String] {
        guard let workspace = try findWorkspace(in: workingDirectory) else { return [] }
        return workspace.data.children.map(\.location.path)
            .filter { $0.hasSuffix(xcodeprojExtension) }
            .map { "\(workingDirectory.path)/\($0)" }
    }
}
