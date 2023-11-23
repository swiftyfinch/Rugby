import Fish
import Foundation

final class BinariesCleaner: Loggable {
    let logger: ILogger
    private let limit: Int
    private let sharedRugbyFolderPath: String
    private let binariesFolderPath: String
    private let localRugbyFolderPath: String
    private let buildFolderPath: String

    private let binariesPathDepth = 4
    private let reserveMultiplier = 1.2 // 20%
    private let freeMultiplier = 0.4 // 40%
    private let formatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB]
        return formatter
    }()

    init(logger: ILogger,
         limit: Int,
         sharedRugbyFolderPath: String,
         binariesFolderPath: String,
         localRugbyFolderPath: String,
         buildFolderPath: String) {
        self.logger = logger
        self.limit = limit
        self.sharedRugbyFolderPath = sharedRugbyFolderPath
        self.binariesFolderPath = binariesFolderPath
        self.localRugbyFolderPath = localRugbyFolderPath
        self.buildFolderPath = buildFolderPath
    }

    func freeSpace() async throws {
        let cleanUpInfo = try await log("Calculating Storage Info", level: .info, auto: await calculateCleanUpInfo())
        let usedPercent = cleanUpInfo.used.percent(total: limit)
        await log("Used: \(formatter.string(fromByteCount: Int64(cleanUpInfo.used))) (\(usedPercent)%)", level: .info)

        guard cleanUpInfo.isCleanUpNeeded else { return }
        await log("Used: \(formatter.string(fromByteCount: Int64(cleanUpInfo.used)))", level: .info)
        await log("Reserved: \(formatter.string(fromByteCount: Int64(cleanUpInfo.reserved)))", level: .info)
        await log("Limit: \(formatter.string(fromByteCount: Int64(limit)))", level: .info)
        await log("To Free: \(formatter.string(fromByteCount: Int64(cleanUpInfo.spaceToFree)))", level: .info)

        let candidatesForDeletion = try await log("Finding Candidates", level: .info, auto: findCandidatesForDeletion())
        let filesForDeletion = try await log(
            "Selecting Binaries",
            level: .info,
            auto: await selectFoldersForDeletion(in: candidatesForDeletion, spaceToFree: cleanUpInfo.spaceToFree)
        )
        let logText = filesForDeletion.reduce(into: "Folders For Deletion:\n") { text, group in
            text.append("\(group.key)\n")
            text.append(group.value.reduce(into: "") { text, info in
                text.append(info.delete ? "- \(info.path)\n" : "+ \(info.path)\n")
            })
        }
        await log(logText, level: .info)

        try await log("Removing files", level: .info, block: {
            let pathsForDeletion = filesForDeletion.reduce(into: []) { paths, group in
                paths.append(contentsOf: group.value.lazy.filter(\.delete).map(\.path))
            }
            try await Set(pathsForDeletion).concurrentForEach { path in
                try File.delete(at: path)
            }
        })

        var emptyFoldersLogText = ""
        let emptyFolders = try Folder.at(binariesFolderPath).folders(deep: true).filter { folder in
            try folder.isEmpty()
        }
        for folder in emptyFolders {
            try folder.delete()
            emptyFoldersLogText.append("- \(folder.path)\n")
        }
        if emptyFoldersLogText.isNotEmpty {
            await log("Deleted Empty Folders:\n\(emptyFoldersLogText)", level: .info)
        }

        // Always remove build folder (DerivedData)
        try await removeBuildFolder()

        if let used = try await calculateUsedSize() {
            let freed = cleanUpInfo.used - used
            await log("Freed: \(formatter.string(fromByteCount: Int64(freed)))", level: .info)
        }
    }

    // MARK: - Private

    private func calculateUsedSize() async throws -> Int? {
        async let sharedSize = (try? Folder.at(sharedRugbyFolderPath).size()) ?? 0
        async let localSize = (try? Folder.at(localRugbyFolderPath).size()) ?? 0
        return await sharedSize + localSize
    }

    private func calculateCleanUpInfo() async throws -> (
        isCleanUpNeeded: Bool,
        used: Int,
        reserved: Int,
        spaceToFree: Int
    ) {
        guard let used = try await calculateUsedSize() else { return (false, 0, 0, 0) }
        let reserved = Int(Double(used) * reserveMultiplier)
        let spaceToFree = max(0, used - Int(Double(limit) * (1 - freeMultiplier)))
        return (reserved >= limit, used, reserved, spaceToFree)
    }

    private func findCandidatesForDeletion() throws -> [String: [String]] {
        let binariesFolder = try Folder.at(binariesFolderPath)
        return try binariesFolder.folders(deep: true).filter { folder in
            let relativePath = folder.relativePath(to: binariesFolder)
            let pathComponents = relativePath.components(separatedBy: "/")
            return pathComponents.count == binariesPathDepth
        }
        .sorted { lhs, rhs in
            let lhsDate = try lhs.creationDate()
            let rhsDate = try rhs.creationDate()
            return lhsDate.timeIntervalSinceReferenceDate < rhsDate.timeIntervalSinceReferenceDate
        }
        .reduce(into: [:]) { groups, folder in
            guard let parentPath = folder.parent?.path else { return }
            groups[folder.name, default: []].append(parentPath)
        }
    }

    private func selectFoldersForDeletion(
        in groups: [String: [String]],
        spaceToFree: Int
    ) async throws -> [String: [(path: String, delete: Bool)]] {
        var collectedSize = 0
        var copiesCount = 0
        var foldersForDeletion: [String: [(String, delete: Bool)]] = [:]
        while collectedSize < spaceToFree {
            let previousCollectedSize = collectedSize
            for (folderName, paths) in groups where copiesCount < paths.count {
                let path = paths[copiesCount]
                let size = try Folder.size(at: path)
                guard copiesCount + 1 < paths.count, size > 0 else {
                    foldersForDeletion[folderName, default: []].append((path, false))
                    continue
                }

                foldersForDeletion[folderName, default: []].append((path, true))
                collectedSize += size
            }

            if collectedSize == previousCollectedSize {
                await log("Can't add more paths to free space", level: .info)
                break
            }
            copiesCount += 1
        }
        return foldersForDeletion
    }

    private func removeBuildFolder() async throws {
        guard Folder.isExist(at: buildFolderPath) else { return }

        try await log("Removing build folder", level: .info, block: {
            let buildFolder = try Folder.at(buildFolderPath)
            let files = try buildFolder.files(deep: true)
            try await files.concurrentForEach { file in
                try file.delete()
            }
            try buildFolder.delete()
        })
    }
}
