//
//  XcodeProj+RemoveSchemes.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 14.02.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import XcodeProj

extension XcodeProj {
    func removeSchemes(pods: Set<String>, projectPath: String) throws {
        let remainingTargets = pbxproj.main.targets.filter { !pods.contains($0.name) }
        var remainingUUIDs = Set(remainingTargets.map(\.uuid))

        if !projectPath.hasSuffix(.podsProject) {
            let podsProject = try ProjectProvider.shared.readProject(.podsProject)
            remainingUUIDs.formUnion(podsProject.pbxproj.main.targets.map(\.uuid))
        }

        let customSchemesForRemove = (sharedData?.schemes ?? []).filter { scheme in
            scheme.testAction?.testables.removeAll {
                guard let blueprintIdentifier = $0.buildableReference.blueprintIdentifier else {
                    return false
                }
                return !remainingUUIDs.contains(blueprintIdentifier)
            }

            let profileActionReference = scheme.profileAction?.buildableProductRunnable?.buildableReference
            if let id = profileActionReference?.blueprintIdentifier, !remainingUUIDs.contains(id) {
                scheme.profileAction?.buildableProductRunnable = nil
            }

            scheme.buildAction?.buildActionEntries.removeAll {
                guard let blueprintIdentifier = $0.buildableReference.blueprintIdentifier else {
                    return false
                }
                return !remainingUUIDs.contains(blueprintIdentifier)
            }

            let launchActionReference = scheme.launchAction?.runnable?.buildableReference
            if let id = launchActionReference?.blueprintIdentifier, !remainingUUIDs.contains(id) {
                scheme.launchAction?.runnable = nil
            }

            return (scheme.testAction?.testables ?? []).isEmpty
                && (scheme.buildAction?.buildActionEntries ?? []).isEmpty
                && scheme.profileAction?.buildableProductRunnable == nil
                && scheme.launchAction?.runnable == nil
        }

        let schemesForRemove = customSchemesForRemove.map(\.name) + pods

        // Anyway remove schemes from project
        defer { sharedData?.schemes.removeAll { schemesForRemove.contains($0.name) } }

        schemesForRemove.forEach {
            let sharedSchemes = try? Folder(path: projectPath + "/xcshareddata/xcschemes")
            try? sharedSchemes?.file(at: $0 + ".xcscheme").delete()
        }

        let username = try shell("echo ${USER}")
        schemesForRemove.forEach {
            let userSchemesFolder = try? Folder(path: projectPath + "/xcuserdata/\(username).xcuserdatad/xcschemes")
            try? userSchemesFolder?.file(at: $0 + ".xcscheme").delete()
        }
    }
}
