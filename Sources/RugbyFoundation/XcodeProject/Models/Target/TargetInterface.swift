import XcodeProj

/// The model describing Xcode project target and its capabilities.
public protocol ITarget: AnyObject {}

typealias TargetId = String
typealias TargetsMap = [TargetId: IInternalTarget]
protocol IInternalTarget: ITarget {
    var name: String { get }
    var uuid: TargetId { get }

    var context: [AnyHashable: Any] { get set }
    var explicitDependencies: TargetsMap { get }

    var pbxTarget: PBXTarget { get }
    var project: Project { get }

    var isPodsUmbrella: Bool { get }
    var isNative: Bool { get }
    var isTests: Bool { get }

    /// All dependencies including implicit ones
    var dependencies: TargetsMap { get }

    var product: Product? { get }
    var buildRules: [BuildRule] { get }
    var buildPhases: [BuildPhase] { get }
    var xcconfigPaths: [String] { get }

    var configurations: [String: Configuration]? { get }
    func updateConfigurations()

    var frameworksScriptPath: String? { get }
    var resourcesScriptPath: String? { get }
    func resourceBundleNames() throws -> [String]

    func addDependencies(_ other: TargetsMap)
    func deleteDependencies(_ other: TargetsMap)
    func resetDependencies()
}
