import Fish
import Foundation

// MARK: - Interface

/// The protocol describing a manager to prebuild CocoaPods project.
public protocol IPrebuildManager {
    /// Prebuilds CocoaPods project and keeps binaries.
    /// - Parameters:
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - options: Xcode build options.
    ///   - paths: A collection of Xcode paths.
    func prebuild(
        targetsRegex: NSRegularExpression?,
        exceptTargetsRegex: NSRegularExpression?,
        options: XcodeBuildOptions,
        paths: XcodeBuildPaths
    ) async throws
}

// MARK: - Implementation

final class PrebuildManager: Loggable {
    let logger: ILogger
    private let xcodePhaseEditor: IXcodePhaseEditor
    private let buildManager: IInternalBuildManager
    private let xcodeProject: IInternalXcodeProject
    private let binariesManager: IBinariesStorage

    init(
        logger: ILogger,
        xcodePhaseEditor: IXcodePhaseEditor,
        buildManager: IInternalBuildManager,
        xcodeProject: IInternalXcodeProject,
        binariesManager: IBinariesStorage
    ) {
        self.logger = logger
        self.xcodePhaseEditor = xcodePhaseEditor
        self.buildManager = buildManager
        self.xcodeProject = xcodeProject
        self.binariesManager = binariesManager
    }
}

extension PrebuildManager: IPrebuildManager {
    func prebuild(
        targetsRegex: NSRegularExpression?,
        exceptTargetsRegex: NSRegularExpression?,
        options: XcodeBuildOptions,
        paths: XcodeBuildPaths
    ) async throws {
        let targets = try await buildManager.prepare(targetsRegex: targetsRegex,
                                                     exceptTargetsRegex: exceptTargetsRegex,
                                                     freeSpaceIfNeeded: false,
                                                     patchLibraries: false)
        let targetsTree = targets.merging(targets.flatMapValues(\.dependencies))

        await log("Removing Build Phases") {
            await xcodePhaseEditor.keepOnlyPreSourceScriptPhases(in: targetsTree)
            await xcodePhaseEditor.deleteCopyXCFrameworksPhase(in: targetsTree)
        }
        let targetsWithoutPhases = targetsTree.filter(\.value.buildPhases.isEmpty)
        guard targetsTree.count != targetsWithoutPhases.count else {
            xcodeProject.resetCache()
            return await log("Skip")
        }

        let targetsToBuild: TargetsMap
        if ProcessInfo.processInfo.environment.contains("RUGBY_DELETE_PRE_TARGETS") {
            // Sometimes modules expect that their dependencies create product folder.
            let productFolderPaths = targetsWithoutPhases.values.compactMap { [weak self] target in
                self?.binariesManager.productFolderPath(target: target, options: options, paths: paths)
            }
            try await productFolderPaths.concurrentForEach { try Folder.create(at: $0) }

            // Xcodebuild works faster if we pass less targets.
            try await log("Deleting Targets", auto: await xcodeProject.deleteTargets(targetsWithoutPhases))
            targetsToBuild = targets.subtracting(targetsWithoutPhases)
        } else {
            targetsToBuild = targets
        }

        let buildTarget = try await buildManager.makeBuildTarget(targetsToBuild)
        try await buildManager.build(buildTarget, options: options, paths: paths)
    }
}
