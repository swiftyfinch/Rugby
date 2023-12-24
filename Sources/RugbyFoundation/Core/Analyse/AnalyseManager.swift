import Fish
import Foundation

// MARK: - Interface

/// The protocol describing a manager to analyse hasher of targets.
public protocol IAnalyseHasherManager {
    /// Analyse the hash of targets
    /// - Parameters:
    ///   - missingBinariesOnly: If true, only analyse and output the targets with missting binaries.
    ///   - outputDir: The directory that save the hash results.
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - options: Xcode build options.
    func analyse(missingBinariesOnly: Bool,
                 outputDir: String,
                 targetsRegex: NSRegularExpression?,
                 exceptTargetsRegex: NSRegularExpression?,
                 options: XcodeBuildOptions) async throws
}

// MARK: - Implementation

final class AnalyseHasherManager: Loggable {
    let logger: ILogger
    private let rugbyXcodeProject: RugbyXcodeProject
    private let buildTargetsManager: BuildTargetsManager
    private let targetsHasher: ITargetsHasher
    private let binariesManager: IBinariesStorage

    init(logger: ILogger,
         rugbyXcodeProject: RugbyXcodeProject,
         buildTargetsManager: BuildTargetsManager,
         binariesManager: IBinariesStorage,
         targetsHasher: ITargetsHasher) {
        self.logger = logger
        self.rugbyXcodeProject = rugbyXcodeProject
        self.buildTargetsManager = buildTargetsManager
        self.binariesManager = binariesManager
        self.targetsHasher = targetsHasher
    }
}

// MARK: - IWarmupManager

extension AnalyseHasherManager: IAnalyseHasherManager {
    public func analyse(missingBinariesOnly: Bool,
                        outputDir: String,
                        targetsRegex: NSRegularExpression?,
                        exceptTargetsRegex: NSRegularExpression?,
                        options: XcodeBuildOptions) async throws {
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let targets = try await findLocalBinaries(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: options,
            missingBinariesOnly: missingBinariesOnly
        )

        let folder = try Folder.create(at: outputDir)
        try await targets.concurrentForEach { (_: TargetId, value: IInternalTarget) in
            let fileName = "\(value.name)_\(value.hash ?? "").yaml"
            try folder.createFile(named: fileName, contents: value.hashContext)
        }
        await log("Hash yamls saved at: \(outputDir)", level: .result)
    }

    private func findLocalBinaries(targetsRegex: NSRegularExpression?,
                                   exceptTargetsRegex: NSRegularExpression?,
                                   options: XcodeBuildOptions,
                                   missingBinariesOnly: Bool) async throws -> TargetsMap {
        let targets = try await log(
            "Finding Build Targets",
            auto: await buildTargetsManager.findTargets(targetsRegex, exceptTargets: exceptTargetsRegex)
        )
        guard targets.isNotEmpty else { throw BuildError.cantFindBuildTargets }

        try await log("Hashing Targets", auto: await targetsHasher.hash(targets, xcargs: options.xcargs))

        let (found, notFound) = try await log(
            "Finding Binaries",
            auto: binariesManager.findBinaries(ofTargets: targets, buildOptions: options)
        )

        if !missingBinariesOnly {
            try await printTargets(found, options: options, category: "Found:")
        }
        try await printTargets(notFound, options: options, category: "Not Found:")

        let notFoundPercent = notFound.count.percent(total: targets.count)
        await log("Not Found Locally \(notFoundPercent)% Binaries (\(notFound.count)/\(targets.count))", level: .result)

        return missingBinariesOnly ? notFound : found.merging(notFound)
    }

    private func printTargets(_ targets: TargetsMap, options: XcodeBuildOptions, category: String) async throws {
        await log(category.uppercased(), level: .result)
        let logLevel: LogLevel = .result
        let notFoundPaths = try targets.values
            .map { try "- \(binariesManager.finderBinaryFolderPath($0, buildOptions: options))" }
            .caseInsensitiveSorted()
        await logList(notFoundPaths, level: logLevel)
    }
}
