import XcodeProj

/// The model describing Xcode project target and its capabilities.
public protocol ITarget: AnyObject {}

protocol IInternalTarget: ITarget {
    var name: String { get }
    var uuid: String { get }

    var context: [AnyHashable: Any] { get set }
    var explicitDependencies: [String: IInternalTarget] { get }

    var pbxTarget: PBXTarget { get }
    var project: Project { get }

    var isPodsUmbrella: Bool { get }
    var isNative: Bool { get }
    var isTests: Bool { get }

    /// All dependencies including implicit ones
    var dependencies: [String: IInternalTarget] { get }

    var product: Product? { get }
    var configurations: [String: Configuration]? { get }
    var buildRules: [BuildRule] { get }
    var buildPhases: [BuildPhase] { get }
    var xcconfigPaths: Set<String> { get }

    var frameworksScriptPath: String? { get }
    var resourcesScriptPath: String? { get }
    func resourceBundleNames() throws -> [String]

    func addDependencies(_ other: [String: IInternalTarget])
    func deleteDependencies(_ other: [String: IInternalTarget])
    func resetDependencies()
}
