//
//  GitHubUpdater.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 30.11.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import RugbyFoundation

final class GitHubUpdater: Loggable {
    enum Version {
        case latest
        case some(String)
    }

    struct VersionInfo {
        let newVersion: Version
        let current: String
        let min: String

        init(newVersion: Version, current: String, min: String) {
            self.newVersion = newVersion
            self.current = current
            self.min = min
        }
    }

    enum Error: LocalizedError {
        case couldnotFindLatestVersion
        case versionTooLow(String, minimalVersion: String)
        case incorrectBinaryPath(String, correctPath: String)
        case couldNotFindBinaryPath

        var errorDescription: String? {
            switch self {
            case .couldnotFindLatestVersion:
                return "Couldn't find latest version."
            case let .versionTooLow(version, minimalVersion):
                return """
                Version too low \(version)
                \("🚑 Minimal version is \(minimalVersion)".yellow)
                """
            case let .incorrectBinaryPath(incorrectPath, correctPath):
                return """
                Couldn't update binary on this path
                \(incorrectPath.homeFinderRelativePath())
                \("🚑 Move binary to \(correctPath.homeFinderRelativePath())".yellow)
                """
            case .couldNotFindBinaryPath:
                return "Couldn't find binary path."
            }
        }
    }

    let logger: ILogger
    private let releaseListLoader: GitHubReleaseListLoader
    private let binaryInstaller: GitHubBinaryInstaller
    private let versionParser: VersionParser
    private let shellExecutor: IShellExecutor

    private let maxLatestReleasesCount = 30

    init(logger: ILogger,
         releaseListLoader: GitHubReleaseListLoader,
         binaryInstaller: GitHubBinaryInstaller,
         versionParser: VersionParser,
         shellExecutor: IShellExecutor) {
        self.logger = logger
        self.releaseListLoader = releaseListLoader
        self.binaryInstaller = binaryInstaller
        self.versionParser = versionParser
        self.shellExecutor = shellExecutor
    }

    func update(to versionInfo: VersionInfo,
                binaryName: String,
                allowBeta: Bool,
                architecture: GitHubUpdaterArchitecture?,
                force: Bool) async throws {
        let binaryPath = try getBinaryPath(binaryName: binaryName)
        guard binaryPath.homeFinderRelativePath() == binaryInstaller.paths.cltPath.homeFinderRelativePath() else {
            throw Error.incorrectBinaryPath(binaryPath, correctPath: binaryInstaller.paths.cltPath)
        }

        let architecture = try architecture ?? currentArchitecture(binaryPath: binaryPath)
        let currentVersion = try versionParser.parse(versionInfo.current)
        let minVersionString = versionInfo.min
        let minVersion = try versionParser.parse(versionInfo.min)

        let stringVersion: String
        let parsedVersion: GitHubUpdaterVersion
        switch versionInfo.newVersion {
        case .latest:
            let releases = try await log("Loading Releases",
                                         auto: try await list(count: maxLatestReleasesCount,
                                                              architecture: architecture,
                                                              minVersion: minVersion))
            guard let latest = releases.first(where: { allowBeta || !$0.prerelease })
            else { throw Error.couldnotFindLatestVersion }

            parsedVersion = try versionParser.parse(latest.version)
            guard force || parsedVersion > currentVersion else {
                await log("You’re up to date!")
                return
            }
            stringVersion = latest.version
        case .some(let version):
            parsedVersion = try versionParser.parse(version)
            stringVersion = version
        }

        guard parsedVersion >= minVersion else {
            throw Error.versionTooLow(stringVersion, minimalVersion: minVersionString)
        }

        try await binaryInstaller.install(version: stringVersion, architecture: architecture)
    }

    func list(count: Int,
              architecture: GitHubUpdaterArchitecture? = nil,
              minVersion: String,
              binaryName: String) async throws -> [Release] {
        let minVersion = try versionParser.parse(minVersion)
        let binaryPath = try getBinaryPath(binaryName: binaryName)
        let architecture = try architecture ?? currentArchitecture(binaryPath: binaryPath)
        return try await releaseListLoader.load(count: count, architecture: architecture).filter {
            try versionParser.parse($0.version) >= minVersion
        }
    }

    private func list(count: Int,
                      architecture: GitHubUpdaterArchitecture,
                      minVersion: GitHubUpdaterVersion) async throws -> [Release] {
         return try await releaseListLoader.load(count: count, architecture: architecture).filter {
             try versionParser.parse($0.version) >= minVersion
         }
     }

    private func getBinaryPath(binaryName: String) throws -> String {
        guard let binaryPath = try shellExecutor.throwingShell("where \(binaryName)") else {
            throw Error.couldNotFindBinaryPath
        }
        return binaryPath
    }

    private func currentArchitecture(binaryPath: String) throws -> GitHubUpdaterArchitecture {
        // Example:
        // Non-fat file: /Users/swiftyfinch/.rugby/clt/rugby is architecture: x86_64
        guard let output = try shellExecutor.throwingShell("lipo -i \(binaryPath)"),
              let archPart = output.components(separatedBy: "architecture: ").last,
              let architecture = GitHubUpdaterArchitecture(rawValue: archPart) else { return .x86_64 }
        return architecture
    }
}
