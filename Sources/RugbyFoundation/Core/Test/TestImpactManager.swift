import Foundation

// MARK: - Interface

/// The protocol describing a manager to analyse test targets in CocoaPods project.
public protocol ITestImpactManager: AnyObject {
    /// Prints affected test targets.
    /// - Parameters:
    ///   - targetsOptions: A set of options to to select targets.
    ///   - options: Xcode build options.
    func impact(targetsOptions: TargetsOptions,
                buildOptions: XcodeBuildOptions) async throws

    /// Marks test targets as passed.
    /// - Parameters:
    ///   - targetsOptions: A set of options to to select targets.
    ///   - options: Xcode build options.
    ///   - upToDateBranch: Skip if the current branch is not up-to-date to target one.
    func markAsPassed(targetsOptions: TargetsOptions,
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
    private let targetsPrinter: ITargetsPrinter

    init(logger: ILogger,
         environmentCollector: IEnvironmentCollector,
         rugbyXcodeProject: IRugbyXcodeProject,
         buildTargetsManager: IBuildTargetsManager,
         targetsHasher: ITargetsHasher,
         testsStorage: ITestsStorage,
         git: IGit,
         targetsPrinter: ITargetsPrinter) {
        self.logger = logger
        self.environmentCollector = environmentCollector
        self.rugbyXcodeProject = rugbyXcodeProject
        self.buildTargetsManager = buildTargetsManager
        self.targetsHasher = targetsHasher
        self.testsStorage = testsStorage
        self.git = git
        self.targetsPrinter = targetsPrinter
    }
}

protocol IInternalTestImpactManager: ITestImpactManager {
    func fetchTestTargets(targetsOptions: TargetsOptions,
                          buildOptions: XcodeBuildOptions,
                          quiet: Bool) async throws -> TargetsMap
    func missingTargets(targetsOptions: TargetsOptions,
                        buildOptions: XcodeBuildOptions,
                        quiet: Bool) async throws -> TargetsMap
}

extension TestImpactManager: IInternalTestImpactManager {
    func fetchTestTargets(targetsOptions: TargetsOptions,
                          buildOptions: XcodeBuildOptions,
                          quiet: Bool) async throws -> TargetsMap {
        let targets = try await log(
            "Finding Targets",
            level: quiet ? .info : .compact,
            auto: await buildTargetsManager.findTargets(
                targetsOptions.targetsRegex,
                exceptTargets: targetsOptions.exceptTargetsRegex,
                includingTests: true
            )
        )
        if targetsOptions.tryMode { return targets }
        try await log("Hashing Targets",
                      level: quiet ? .info : .compact,
                      auto: await targetsHasher.hash(targets, xcargs: buildOptions.xcargs))
        return targets.filter(\.value.isTests)
    }

    func missingTargets(targetsOptions: TargetsOptions,
                        buildOptions: XcodeBuildOptions,
                        quiet: Bool) async throws -> TargetsMap {
        let targets = try await fetchTestTargets(
            targetsOptions: targetsOptions,
            buildOptions: buildOptions,
            quiet: quiet
        )
        return try await testsStorage.findMissingTests(of: targets, buildOptions: buildOptions)
    }
}

extension TestImpactManager: ITestImpactManager {
    func impact(targetsOptions: TargetsOptions,
                buildOptions: XcodeBuildOptions) async throws {
        try await environmentCollector.logXcodeVersion()
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let targets = try await fetchTestTargets(
            targetsOptions: targetsOptions,
            buildOptions: buildOptions,
            quiet: false
        )
        if targetsOptions.tryMode {
            return await targetsPrinter.print(targets)
        }

        let missingTestTargets = try await testsStorage.findMissingTests(of: targets, buildOptions: buildOptions)
        guard !missingTestTargets.isEmpty else {
            await log("No Affected Test Targets")
            return
        }

        await log("Affected Test Targets (\(missingTestTargets.count))") {
            for target in missingTestTargets.caseInsensitiveSortedByName() {
                guard let hash = target.hash else { continue }
                await log("\(target.name) (\(hash))", level: .result)
            }
        }
    }

    func markAsPassed(targetsOptions: TargetsOptions,
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
            targetsOptions: targetsOptions,
            buildOptions: buildOptions,
            quiet: false
        )
        if targetsOptions.tryMode {
            return await targetsPrinter.print(targets)
        }
        try await log(
            "Marking Tests as Passed",
            auto: await testsStorage.saveTests(of: targets, buildOptions: buildOptions)
        )
    }
}
