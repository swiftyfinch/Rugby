import Foundation
import RugbyFoundation

// MARK: - Interface

struct GitHubUpdaterVersion: Comparable {
    enum Prerelease: Int, Comparable {
        case beta = 0
        case prod = 1

        static func < (lhs: Prerelease, rhs: Prerelease) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    let major: Int
    let minor: Int
    let patch: Int
    let prerelease: Prerelease
    let build: Int

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.major, lhs.minor, lhs.patch, lhs.prerelease, lhs.build) <
            (rhs.major, rhs.minor, rhs.patch, rhs.prerelease, rhs.build)
    }
}

enum VersionParserError: LocalizedError {
    case incorrectVersion(String)

    var errorDescription: String? {
        switch self {
        case let .incorrectVersion(version):
            return "Incorrect version: \(version)"
        }
    }
}

// MARK: - Implementation

final class VersionParser {
    private typealias Error = VersionParserError
    func parse(_ string: String) throws -> GitHubUpdaterVersion {
        let groups = try string.groups(regex: "(\\d+)\\.(\\d+)\\.(\\d+)(b?)(\\d*)")
        guard groups.count > 3,
              let major = Int(groups[1]),
              let minor = Int(groups[2]),
              let patch = Int(groups[3]) else { throw Error.incorrectVersion(string) }

        let prerelease: GitHubUpdaterVersion.Prerelease
        if groups.count > 4, !groups[4].isEmpty {
            if groups[4] == "b" {
                prerelease = .beta
            } else {
                throw Error.incorrectVersion(string)
            }
        } else {
            prerelease = .prod
        }

        let build: Int
        if groups.count > 5, !groups[5].isEmpty {
            guard let int = Int(groups[5]) else { throw Error.incorrectVersion(string) }
            build = int
        } else {
            build = 0
        }

        return GitHubUpdaterVersion(major: major,
                                    minor: minor,
                                    patch: patch,
                                    prerelease: prerelease,
                                    build: build)
    }
}
