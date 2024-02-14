import Foundation
import XcodeProj

final class Target: IInternalTarget {
    var context: [AnyHashable: Any] = [:]
    private(set) var explicitDependencies: TargetsMap

    internal let pbxTarget: PBXTarget
    internal let project: IProject
    internal let projectBuildConfigurations: [String: XCBuildConfiguration]

    // MARK: - Lazy Properties

    private(set) lazy var isPodsUmbrella = pbxTarget.name.hasPrefix("Pods-")
    private(set) lazy var isNative = pbxTarget is PBXNativeTarget
    private(set) lazy var isTests = pbxTarget.isTests
    private(set) lazy var isApplication = (pbxTarget.productType == .application)

    /// All dependencies including implicit ones
    private(set) lazy var dependencies = collectDependencies()
    private(set) lazy var products = collectProducts()

    private(set) lazy var product = try? pbxTarget.constructProduct(configurations?.first?.value.buildSettings)
    private(set) lazy var configurations = constructConfigurations()
    private(set) lazy var buildRules = pbxTarget.constructBuildRules()
    private(set) lazy var buildPhases = pbxTarget.constructBuildPhases()
    private(set) lazy var xcconfigPaths = pbxTarget.xcconfigPaths()
    private(set) lazy var frameworksScriptPath = pbxTarget.frameworksScriptPath(xcconfigPaths: xcconfigPaths)
    private(set) lazy var resourcesScriptPath = pbxTarget.resourcesScriptPath(xcconfigPaths: xcconfigPaths)

    // MARK: - Computed Properties

    var name: String { pbxTarget.name }
    internal var uuid: TargetId { pbxTarget.uuid }

    init(pbxTarget: PBXTarget,
         project: IProject,
         explicitDependencies: TargetsMap = [:],
         projectBuildConfigurations: [String: XCBuildConfiguration]) {
        self.pbxTarget = pbxTarget
        self.project = project
        self.explicitDependencies = explicitDependencies
        self.projectBuildConfigurations = projectBuildConfigurations
    }

    // MARK: - Methods

    func updateConfigurations() {
        configurations = constructConfigurations()
    }

    private func constructConfigurations() -> [String: Configuration]? {
        try? pbxTarget.constructConfigurations(projectBuildConfigurations)
    }

    private func collectDependencies() -> TargetsMap {
        explicitDependencies.reduce(into: explicitDependencies) { collection, dependency in
            collection.merge(dependency.value.dependencies)
        }
    }

    private func collectProducts() -> [String: Product] {
        dependencies.compactMapValues(\.product)
    }
}

// MARK: - Dependencies Methods

extension Target {
    func addDependencies(_ other: TargetsMap) {
        explicitDependencies.merge(other)
    }

    func deleteDependencies(_ other: TargetsMap) {
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
