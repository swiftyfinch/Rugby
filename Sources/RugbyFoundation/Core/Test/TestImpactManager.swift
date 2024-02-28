import Foundation

// MARK: - Interface

/// The protocol describing a manager to analyse test targets in CocoaPods project.
public protocol ITestImpactManager {
    /// Prints affected test targets.
    /// - Parameters:
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - options: Xcode build options.
    func impact(targetsRegex: NSRegularExpression?,
                exceptTargetsRegex: NSRegularExpression?,
                buildOptions: XcodeBuildOptions) async throws

    /// Marks test targets as passed.
    /// - Parameters:
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - options: Xcode build options.
    ///   - upToDateBranch: Skip if the current branch is not up-to-date to target one.
    func markAsPassed(targetsRegex: NSRegularExpression?,
                      exceptTargetsRegex: NSRegularExpression?,
                      buildOptions: XcodeBuildOptions,
                      upToDateBranch: String?) async throws
}

// MARK: - Implementation

final class TestImpactManager: Loggable {
    let logger: ILogger
    private let environmentCollector: IEnvironmentCollector
    private let rugbyXcodeProject: IRugbyXcodeProject
    private let buildTargetsManager: IBuildTargetsManager
    private let targetsHasher: ITargetsHasher
    private let testsStorage: ITestsStorage
    private let git: IGit

    init(logger: ILogger,
         environmentCollector: IEnvironmentCollector,
         rugbyXcodeProject: IRugbyXcodeProject,
         buildTargetsManager: IBuildTargetsManager,
         targetsHasher: ITargetsHasher,
         testsStorage: ITestsStorage,
         git: IGit) {
        self.logger = logger
        self.environmentCollector = environmentCollector
        self.rugbyXcodeProject = rugbyXcodeProject
        self.buildTargetsManager = buildTargetsManager
        self.targetsHasher = targetsHasher
        self.testsStorage = testsStorage
        self.git = git
    }
}

protocol IInternalTestImpactManager: ITestImpactManager {
    func fetchTestTargets(_ targetsRegex: NSRegularExpression?,
                          exceptTargetsRegex: NSRegularExpression?,
                          buildOptions: XcodeBuildOptions) async throws -> TargetsMap
    func missingTargets(_ targetsRegex: NSRegularExpression?,
                        exceptTargetsRegex: NSRegularExpression?,
                        buildOptions: XcodeBuildOptions) async throws -> TargetsMap
}

extension TestImpactManager: IInternalTestImpactManager {
    func fetchTestTargets(_ targetsRegex: NSRegularExpression?,
                          exceptTargetsRegex: NSRegularExpression?,
                          buildOptions: XcodeBuildOptions) async throws -> TargetsMap {
        let targets = try await log(
            "Finding Targets",
            auto: await buildTargetsManager.findTargets(
                targetsRegex,
                exceptTargets: exceptTargetsRegex,
                includingTests: true
            )
        )
        try await log("Hashing Targets", auto: await targetsHasher.hash(targets, xcargs: buildOptions.xcargs))
        return targets.filter(\.value.isTests)
    }

    func missingTargets(_ targetsRegex: NSRegularExpression?,
                        exceptTargetsRegex: NSRegularExpression?,
                        buildOptions: XcodeBuildOptions) async throws -> TargetsMap {
        let targets = try await fetchTestTargets(
            targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            buildOptions: buildOptions
        )
        return try await testsStorage.findMissingTests(of: targets, buildOptions: buildOptions)
    }
}

extension TestImpactManager: ITestImpactManager {
    func impact(targetsRegex: NSRegularExpression?,
                exceptTargetsRegex: NSRegularExpression?,
                buildOptions: XcodeBuildOptions) async throws {
        try await environmentCollector.logXcodeVersion()
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let targets = try await fetchTestTargets(
            targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            buildOptions: buildOptions
        )

        let missingTestTargets = try await testsStorage.findMissingTests(of: targets, buildOptions: buildOptions)
        guard !missingTestTargets.isEmpty else {
            await log("No Affected Test Targets")
            return
        }

        await log("Affected Test Targets (\(missingTestTargets.count))") {
            for target in missingTestTargets.values {
                guard let hash = target.hash else { continue }
                await log("\(target.name) (\(hash))", level: .result)
            }
        }
    }

    func markAsPassed(targetsRegex: NSRegularExpression?,
                      exceptTargetsRegex: NSRegularExpression?,
                      buildOptions: XcodeBuildOptions,
                      upToDateBranch: String?) async throws {
        if let branch = upToDateBranch {
            guard try !git.hasUncommittedChanges() else {
                return await log("Skip: The current branch has uncommitted changes.")
            }
            guard try !git.isBehind(branch: branch) else {
                return await log("Skip: The current branch is behind \(branch).")
            }
        }

        try await environmentCollector.logXcodeVersion()
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let targets = try await fetchTestTargets(
            targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            buildOptions: buildOptions
        )
        try await log(
            "Marking Tests as Passed",
            auto: await testsStorage.saveTests(of: targets, buildOptions: buildOptions)
        )
    }
}
