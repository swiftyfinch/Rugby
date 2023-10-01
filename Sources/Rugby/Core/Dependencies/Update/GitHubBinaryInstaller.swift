import Fish
import Foundation
import RugbyFoundation

// MARK: - Interface

enum GitHubUpdaterArchitecture: String {
    case x86_64, arm64 // swiftlint:disable:this identifier_name
}

struct GitHubUpdaterPaths {
    let downloadsPath: String
    let cltFolderPath: String
    let cltName: String
    let cltPath: String
    let repositoryPath: String

    init(downloadsPath: String,
         cltFolderPath: String,
         cltName: String,
         repositoryPath: String) {
        self.downloadsPath = downloadsPath
        self.cltFolderPath = cltFolderPath
        self.cltName = cltName
        cltPath = "\(cltFolderPath)/\(cltName)"
        self.repositoryPath = repositoryPath
    }
}

enum GitHubBinaryInstallerError: LocalizedError {
    case incorrectZipURL(String)
    case couldnotFindVersion(String)
    case incorrectResponse

    var errorDescription: String? {
        switch self {
        case let .incorrectZipURL(url):
            return "Incorrect zip URL \(url)"
        case let .couldnotFindVersion(version):
            return "Couldn't find such version \(version)"
        case .incorrectResponse:
            return "Incorrect response."
        }
    }
}

// MARK: - Implementation

final class GitHubBinaryInstaller: Loggable {
    private typealias Error = GitHubBinaryInstallerError
    let paths: GitHubUpdaterPaths
    let logger: ILogger
    private let shellExecutor: IShellExecutor

    init(paths: GitHubUpdaterPaths,
         logger: ILogger,
         shellExecutor: IShellExecutor) {
        self.paths = paths
        self.logger = logger
        self.shellExecutor = shellExecutor
    }

    func install(version: String, architecture: GitHubUpdaterArchitecture) async throws {
        let zipURL = try zipURL(version: version, architecture: architecture)
        guard try await checkURLIsReachable(zipURL) else { throw Error.couldnotFindVersion(version) }

        let downloads = try Folder.create(at: paths.downloadsPath)
        try downloads.emptyFolder()

        await log("v\(version) (\(architecture.rawValue))")
        let (fileURL, _) = try await log("Downloading",
                                         auto: await URLSession.shared.download(from: zipURL))
        try await log("Unzipping",
                      auto: shellExecutor.throwingShell("unzip", args: fileURL.path, "-d", downloads.path))

        try await log("Installing into \(paths.cltFolderPath.homeFinderRelativePath())", block: {
            let cltFile = try downloads.file(named: paths.cltName)
            try cltFile.move(to: paths.cltFolderPath, replace: true)
            try downloads.delete()
        })
    }

    // MARK: - Private

    private func zipURL(version: String, architecture: GitHubUpdaterArchitecture) throws -> URL {
        let releaseURLString = "https://github.com/\(paths.repositoryPath)/releases/download/\(version)"
        let wholeURLString = "\(releaseURLString)/\(architecture.rawValue).zip"
        guard let url = URL(string: wholeURLString) else {
            throw Error.incorrectZipURL(wholeURLString)
        }
        return url
    }

    private func checkURLIsReachable(_ url: URL) async throws -> Bool {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = (response as? HTTPURLResponse) else { throw Error.incorrectResponse }
        return httpResponse.statusCode == 200
    }
}
