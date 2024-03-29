import Foundation
import XcodeProj

enum AddDependencyError: LocalizedError {
    case missingProjectReference(String)
    case emptyProjectPath(String?)
    case cantCreateGroup(String)

    var errorDescription: String? {
        switch self {
        case let .missingProjectReference(name):
            return "Missing project reference '\(name)'."
        case let .emptyProjectPath(name):
            return "Empty project path '\(name ?? "Unknown")'."
        case let .cantCreateGroup(groupName):
            return "Can't create group '\(groupName)'."
        }
    }
}

extension PBXProj {
    func addDependencies(_ dependencies: TargetsMap, target: IInternalTarget) throws {
        try dependencies.values.forEach { dependency in
            try addDependency(dependency, toTarget: target.pbxTarget)
        }
        target.addDependencies(dependencies)
    }

    @discardableResult
    func addDependency(_ dependency: IInternalTarget, toTarget target: PBXTarget) throws -> PBXTargetDependency {
        let proxyType: PBXContainerItemProxy.ProxyType
        let containerPortal: PBXContainerItemProxy.ContainerPortal
        if let reference = dependency.project.reference {
            if let existingReference = projectReferences().first(where: { $0.name == reference.name }) {
                containerPortal = .fileReference(existingReference)
            } else {
                let newReference = reference.copy()
                newReference.fixRelativeProjectPath()
                add(object: newReference)

                // Add project dependency to root Dependencies group
                let dependenciesGroup = try createGroupIfNeeded(groupName: .dependenciesGroup)
                dependenciesGroup.children.append(newReference)
                rootObject?.projects.append([.projectRefKey: newReference])

                containerPortal = .fileReference(newReference)
            }
            proxyType = .reference
        } else {
            proxyType = .nativeTarget
            let pbxProject = try dependency.project.pbxProject
            containerPortal = .project(pbxProject)
        }
        let proxy = PBXContainerItemProxy(containerPortal: containerPortal,
                                          remoteGlobalID: .string(dependency.uuid),
                                          proxyType: proxyType,
                                          remoteInfo: dependency.name)
        add(object: proxy)

        let targetDependency = PBXTargetDependency(name: dependency.name, targetProxy: proxy)
        add(object: targetDependency)
        target.dependencies.append(targetDependency)
        return targetDependency
    }

    func deleteDependencies(_ dependencies: TargetsMap, target: IInternalTarget) {
        let dependenciesUUIDs = dependencies.values.map(\.pbxTarget.uuid).set()
        let pbxDependencies = target.pbxTarget.dependencies.filter {
            guard let remoteGlobalID = $0.targetProxy?.remoteGlobalID else { return false }
            switch remoteGlobalID {
            case let .object(object):
                return dependenciesUUIDs.contains(object.uuid)
            case let .string(uuid):
                return dependenciesUUIDs.contains(uuid)
            }
        }
        pbxDependencies.forEach {
            $0.targetProxy.map(delete)
            delete(object: $0)
        }
        target.pbxTarget.dependencies.removeAll(where: pbxDependencies.contains)
        target.deleteDependencies(dependencies)
    }
}

private extension PBXFileReference {
    func fixRelativeProjectPath() {
        // Sometimes a project path is relative to the project:
        // For example, '../../Pods/SnapKit.xcodeproj' should be 'SnapKit.xcodeproj'.
        path = path.map(URL.init(fileURLWithPath:))?.lastPathComponent
    }

    func copy() -> PBXFileReference {
        PBXFileReference(
            sourceTree: sourceTree,
            name: name,
            fileEncoding: fileEncoding,
            explicitFileType: explicitFileType,
            lastKnownFileType: lastKnownFileType,
            path: path,
            includeInIndex: includeInIndex,
            wrapsLines: wrapsLines,
            usesTabs: usesTabs,
            indentWidth: indentWidth,
            tabWidth: tabWidth,
            lineEnding: lineEnding,
            languageSpecificationIdentifier: languageSpecificationIdentifier,
            xcLanguageSpecificationIdentifier: xcLanguageSpecificationIdentifier,
            plistStructureDefinitionIdentifier: plistStructureDefinitionIdentifier
        )
    }
}

extension PBXProj {
    private func createGroupIfNeeded(groupName: String) throws -> PBXGroup {
        guard let rootGroup = try rootGroup() else { throw AddDependencyError.cantCreateGroup(groupName) }
        if let group = rootGroup.children.first(where: { $0.name == groupName }) as? PBXGroup {
            return group
        } else if let group = try rootGroup.addGroup(named: groupName, options: .withoutFolder).first {
            add(object: group)
            return group
        } else {
            throw AddDependencyError.cantCreateGroup(groupName)
        }
    }
}

private extension String {
    static let dependenciesGroup = "Dependencies"
    static let projectRefKey = "ProjectRef"
}
