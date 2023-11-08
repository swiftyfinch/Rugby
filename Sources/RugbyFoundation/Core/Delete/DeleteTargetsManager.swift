import Foundation

// MARK: - Interface

/// The protocol describing a manager to delete targets from Xcode project.
public protocol IDeleteTargetsManager {
    /// Deletes targets from Xcode project.
    /// - Parameters:
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - keepExceptedTargetsDependencies: A flag to keep dependencies of excepted targets.
    ///   - deleteSources: An option to delete targets with sources from Xcode project.
    func delete(targetsRegex: NSRegularExpression?,
                exceptTargetsRegex: NSRegularExpression?,
                keepExceptedTargetsDependencies: Bool,
                deleteSources: Bool) async throws
}

// MARK: - Implementation

final class DeleteTargetsManager: Loggable {
    let logger: ILogger
    private let xcodeProject: IInternalXcodeProject
    private let backupManager: IBackupManager

    init(logger: ILogger,
         xcodeProject: IInternalXcodeProject,
         backupManager: IBackupManager) {
        self.logger = logger
        self.xcodeProject = xcodeProject
        self.backupManager = backupManager
    }
}

// MARK: - IDeleteTargetsManager

extension DeleteTargetsManager: IDeleteTargetsManager {
    public func delete(targetsRegex: NSRegularExpression?,
                       exceptTargetsRegex: NSRegularExpression?,
                       keepExceptedTargetsDependencies: Bool,
                       deleteSources: Bool) async throws {
        var shouldBeRemoved = try await log(
            "Finding Targets",
            auto: await xcodeProject.findTargets(by: targetsRegex, except: exceptTargetsRegex)
        )
        try await log("Keeping Excepted Targets Dependencies", level: .info, block: {
            if keepExceptedTargetsDependencies {
                try await xcodeProject.findTargets().subtracting(shouldBeRemoved).values.forEach {
                    let intersection = $0.dependencies.keysIntersection(shouldBeRemoved)
                    shouldBeRemoved.subtract(intersection)
                }
            }
        })
        try await log("Backuping", level: .info, auto: await backupManager.backup(xcodeProject, kind: .original))
        try await log("Deleting Targets (\(shouldBeRemoved.count))",
                      auto: await xcodeProject.deleteTargets(shouldBeRemoved, keepGroups: !deleteSources))
        try await log("Saving Project", auto: await xcodeProject.save())
    }
}
