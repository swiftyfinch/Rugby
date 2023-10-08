import Foundation
import XcodeProj

final class Target: IInternalTarget {
    var context: [AnyHashable: Any] = [:]
    private(set) var explicitDependencies: [String: IInternalTarget]

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
         explicitDependencies: [String: IInternalTarget] = [:],
         projectBuildConfigurations: [String: XCBuildConfiguration]) {
        self.pbxTarget = pbxTarget
        self.project = project
        self.explicitDependencies = explicitDependencies
        self.projectBuildConfigurations = projectBuildConfigurations
    }

    // MARK: - Methods

    private func collectDependencies() -> [String: IInternalTarget] {
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
    func addDependencies(_ other: [String: IInternalTarget]) {
        explicitDependencies.merge(other)
    }

    func deleteDependencies(_ other: [String: IInternalTarget]) {
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
