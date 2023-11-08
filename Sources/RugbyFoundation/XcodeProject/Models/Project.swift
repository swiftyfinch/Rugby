import Foundation
import XcodeProj

enum ProjectError: LocalizedError {
    case missingRootProject
    case emptyProjectPath
    case cantReadBuildConfigurations

    var errorDescription: String? {
        switch self {
        case .missingRootProject:
            return "Missing root project."
        case .emptyProjectPath:
            return "Project path is empty."
        case .cantReadBuildConfigurations:
            return "Can't read build configurations."
        }
    }
}

protocol IProject: AnyObject {
    var uuid: String { get throws }
    var xcodeProj: XcodeProj { get }
    var reference: PBXFileReference? { get }
    var path: String { get }
    var pbxProj: PBXProj { get }
    var pbxProject: PBXProject { get throws }
    var buildConfigurationList: XCConfigurationList { get throws }
    var buildConfigurations: [String: XCBuildConfiguration] { get async throws }
}

final class Project: IProject {
    enum Path {
        case string(String)
        case reference(PBXFileReference)

        var reference: PBXFileReference? {
            switch self {
            case .string:
                return nil
            case let .reference(reference):
                return reference
            }
        }

        var string: String? {
            switch self {
            case let .string(path):
                return path
            case let .reference(reference):
                return reference.fullPath
            }
        }
    }

    let xcodeProj: XcodeProj
    let reference: PBXFileReference?
    let path: String

    init(path: Path) throws {
        guard let pathString = path.string else { throw ProjectError.emptyProjectPath }
        self.path = pathString
        xcodeProj = try XcodeProj(pathString: pathString)
        reference = path.reference
    }

    var uuid: String {
        get throws { try pbxProject.uuid }
    }

    var pbxProj: PBXProj { xcodeProj.pbxproj }
    var pbxProject: PBXProject {
        get throws {
            guard let rootProject = try pbxProj.rootProject() else {
                throw ProjectError.missingRootProject
            }
            return rootProject
        }
    }

    var buildConfigurationList: XCConfigurationList {
        get throws {
            try pbxProject.buildConfigurationList
        }
    }

    private var cachedBuildConfigurations: [String: XCBuildConfiguration]?
    var buildConfigurations: [String: XCBuildConfiguration] {
        get async throws {
            if let cachedBuildConfigurations { return cachedBuildConfigurations }
            let buildConfigurations = try buildConfigurationList.buildConfigurations
            let buildConfigurationsMap = Dictionary(uniqueKeysWithValues: buildConfigurations.map { ($0.name, $0) })
            cachedBuildConfigurations = buildConfigurationsMap
            return buildConfigurationsMap
        }
    }
}
