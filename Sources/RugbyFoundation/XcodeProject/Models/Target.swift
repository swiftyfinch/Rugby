//
//  Target.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 27.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import XcodeProj

/// The model describing Xcode project target and its capabilities.
public final class Target {
    var context: [AnyHashable: Any] = [:]
    private(set) var explicitDependencies: Set<Target>

    internal let pbxTarget: PBXTarget
    internal let project: Project
    internal let projectBuildConfigurations: [String: XCBuildConfiguration]

    // MARK: - Lazy Properties

    private(set) lazy var isPodsUmbrella = pbxTarget.name.hasPrefix("Pods-")
    private(set) lazy var isNative = pbxTarget is PBXNativeTarget
    private(set) lazy var isTests = pbxTarget.isTests

    /// All dependencies including implicit ones
    private(set) lazy var dependencies = collectDependencies()
    private(set) lazy var products = collectProducts()

    private(set) lazy var product = try? pbxTarget.constructProduct(configurations?.first?.value.buildSettings)
    private(set) lazy var configurations = try? pbxTarget.constructConfigurations(projectBuildConfigurations)
    private(set) lazy var buildRules = pbxTarget.constructBuildRules()
    private(set) lazy var buildPhases = pbxTarget.constructBuildPhases()
    private(set) lazy var xcconfigPaths = pbxTarget.xcconfigPaths()
    private(set) lazy var frameworksScriptPath = pbxTarget.frameworksScriptPath(xcconfigPaths: xcconfigPaths)
    private(set) lazy var resourcesScriptPath = pbxTarget.resourcesScriptPath(xcconfigPaths: xcconfigPaths)

    // MARK: - Computed Properties

    var name: String { pbxTarget.name }
    internal var uuid: String { pbxTarget.uuid }

    init(pbxTarget: PBXTarget,
         project: Project,
         explicitDependencies: Set<Target> = [],
         projectBuildConfigurations: [String: XCBuildConfiguration]) {
        self.pbxTarget = pbxTarget
        self.project = project
        self.explicitDependencies = explicitDependencies
        self.projectBuildConfigurations = projectBuildConfigurations
    }

    // MARK: - Methods

    private func collectDependencies() -> Set<Target> {
        explicitDependencies.reduce(into: explicitDependencies) { collection, dependency in
            collection.formUnion(dependency.dependencies)
        }
    }

    private func collectProducts() -> Set<Product> {
        dependencies.compactMap(\.product)
    }
}

// MARK: - Dependencies Methods

extension Target {
    func addDependencies(_ other: Set<Target>) {
        explicitDependencies.formUnion(other)
    }

    func deleteDependencies(_ other: Set<Target>) {
        explicitDependencies.subtract(other)
    }

    func resetDependencies() {
        dependencies = collectDependencies()
        products = collectProducts()
    }
}

// MARK: - Phases

extension Target {
    func resourceBundleNames() throws -> [String] {
        guard let resourcesBuildPhase = try pbxTarget.resourcesBuildPhase(),
              let files = resourcesBuildPhase.files else { return [] }

        return files
            .compactMap(\.file?.path)
            .filter { $0.hasSuffix(".bundle") }
            .compactMap { $0.excludingExtension() }
    }
}

// MARK: - Hashable

extension Target: Hashable {
    public static func == (lhs: Target, rhs: Target) -> Bool {
        lhs.pbxTarget == rhs.pbxTarget
    }

    public func hash(into hasher: inout Hasher) {
        pbxTarget.hash(into: &hasher)
    }
}
