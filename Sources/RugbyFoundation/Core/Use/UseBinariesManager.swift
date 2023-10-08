import Foundation

// MARK: - Interface

/// The protocol describing a manager to use built binaries instead of targets in CocoaPods project.
public protocol IUseBinariesManager {
    /// Uses built binaries instead of targets.
    /// - Parameters:
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - xcargs: The xcargs which is used in Rugby.
    ///   - deleteSources: An option to delete targets with sources from Xcode project.
    func use(targetsRegex: NSRegularExpression?,
             exceptTargetsRegex: NSRegularExpression?,
             xcargs: [String],
             deleteSources: Bool) async throws

    /// Uses built binaries instead of targets without saving the project.
    /// - Parameters:
    ///   - targets: A set of targets to select.
    ///   - keepGroups: An option to keep groups after removing targets in Xcode project.
    func use(targets: [String: ITarget],
             keepGroups: Bool) async throws
}

// MARK: - Implementation

final class UseBinariesManager: Loggable {
    let logger: ILogger

    private let buildTargetsManager: BuildTargetsManager
    private let xcodeProject: XcodeProject
    private let rugbyXcodeProject: RugbyXcodeProject
    private let backupManager: IBackupManager
    private let binariesManager: IBinariesStorage
    private let targetsHasher: TargetsHasher
    private let supportFilesPatcher: ISupportFilesPatcher
    private let fileContentEditor: FileContentEditor

    init(logger: ILogger,
         buildTargetsManager: BuildTargetsManager,
         xcodeProject: XcodeProject,
         rugbyXcodeProject: RugbyXcodeProject,
         backupManager: IBackupManager,
         binariesManager: IBinariesStorage,
         targetsHasher: TargetsHasher,
         supportFilesPatcher: ISupportFilesPatcher,
         fileContentEditor: FileContentEditor) {
        self.logger = logger
        self.buildTargetsManager = buildTargetsManager
        self.xcodeProject = xcodeProject
        self.rugbyXcodeProject = rugbyXcodeProject
        self.backupManager = backupManager
        self.binariesManager = binariesManager
        self.targetsHasher = targetsHasher
        self.supportFilesPatcher = supportFilesPatcher
        self.fileContentEditor = fileContentEditor
    }
}

// MARK: - File Replacements

extension UseBinariesManager {
    private func patchProductFiles(binaryTargets: TargetsMap) async throws -> TargetsMap {
        let binaryUsers = try await findBinaryUsers(binaryTargets)
        try binaryUsers.values.forEach { target in
            target.binaryProducts = try target.binaryDependencies.values.compactMap { target in
                guard let product = target.product else { return nil }
                product.binaryPath = try binariesManager.xcodeBinaryFolderPath(target)
                return product
            }
        }

        // For all dynamic frameworks we should keep resource bundles which is produced by targets.
        // The easiest way is just find resource bundle targets and exclude them from reusing from binaries.
        let resourceBundleTargets: TargetsMap = try await binaryUsers.concurrentFlatMapValues { target in
            guard target.product?.type == .framework else { return [:] }

            let resourceBundleNames = try target.resourceBundleNames()
            return binaryTargets.filter {
                guard let productName = $0.value.product?.name else { return false }
                return resourceBundleNames.contains(productName)
            }
        }
        let binaryTargets = binaryTargets.subtracting(resourceBundleTargets)

        let fileReplacements = try await binaryUsers.values.concurrentFlatMap(supportFilesPatcher.prepareReplacements)
        try await fileReplacements.concurrentCompactMap { fileReplacement in
            try self.fileContentEditor.replace(fileReplacement.replacements,
                                               regex: fileReplacement.regex,
                                               filePath: fileReplacement.filePath)
        }

        return binaryTargets
    }

    private func findBinaryUsers(_ binaryTargets: TargetsMap) async throws -> TargetsMap {
        let binaryUsers = try await xcodeProject.findTargets().subtracting(binaryTargets)
        binaryUsers.values.forEach { target in
            target.binaryDependencies = target.dependencies.keysIntersection(binaryTargets)
        }
        return binaryUsers.filter(\.value.binaryDependencies.isNotEmpty)
    }
}

// MARK: - Context Properties

extension IInternalTarget {
    var binaryProducts: [Product] {
        get { (context[String.binaryProductsKey] as? [Product]) ?? [] }
        set { context[String.binaryProductsKey] = newValue }
    }
}

extension Product {
    var binaryPath: String? {
        get { context[String.binaryPathKey] as? String }
        set { context[String.binaryPathKey] = newValue }
    }
}

private extension IInternalTarget {
    var binaryDependencies: TargetsMap {
        get { (context[String.binaryDependenciesKey] as? TargetsMap) ?? [:] }
        set { context[String.binaryDependenciesKey] = newValue }
    }
}

private extension String {
    static let binaryDependenciesKey = "BINARY_DEPENDENCIES"
    static let binaryProductsKey = "BINARY_PRODUCTS"
    static let binaryPathKey = "BINARY_PATH"
}

// MARK: - IUseBinariesManager

extension UseBinariesManager: IUseBinariesManager {
    public func use(targetsRegex: NSRegularExpression?,
                    exceptTargetsRegex: NSRegularExpression?,
                    xcargs: [String],
                    deleteSources: Bool) async throws {
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }
        let binaryTargets = try await log(
            "Finding Build Targets",
            auto: await buildTargetsManager.findTargets(targetsRegex, exceptTargets: exceptTargetsRegex)
        )
        try await log("Hashing Targets", auto: await targetsHasher.hash(binaryTargets, xcargs: xcargs))
        try await log("Backuping", auto: await backupManager.backup(xcodeProject, kind: .original))
        try await use(targets: binaryTargets, keepGroups: !deleteSources)
        try await rugbyXcodeProject.markAsUsingRugby()
        try await log("Saving Project", auto: await xcodeProject.save())
    }

    public func use(targets: [String: ITarget], keepGroups: Bool) async throws {
        let internalTargets = targets.compactMapValues { $0 as? IInternalTarget }
        let binaryTargets = try await log("Patching Product Files",
                                          auto: await patchProductFiles(binaryTargets: internalTargets))
        try await log(
            "Deleting Targets (\(binaryTargets.count))",
            auto: await xcodeProject.deleteTargets(binaryTargets, keepGroups: keepGroups)
        )
    }
}
