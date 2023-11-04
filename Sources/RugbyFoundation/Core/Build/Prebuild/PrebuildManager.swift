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

    init(
        logger: ILogger,
        xcodePhaseEditor: IXcodePhaseEditor,
        buildManager: IInternalBuildManager,
        xcodeProject: IInternalXcodeProject
    ) {
        self.logger = logger
        self.xcodePhaseEditor = xcodePhaseEditor
        self.buildManager = buildManager
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
        await log("Removing Build Phases", auto: await xcodePhaseEditor.keepOnlyPreSourcePhases(from: targetsTree))
        let buildTarget = try await buildManager.makeBuildTarget(targets)
        try await buildManager.build(buildTarget, options: options, paths: paths)
    }
}
