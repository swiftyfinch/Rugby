import Foundation
import RugbyFoundation

// MARK: - Interface

struct Release {
    let name: String
    let version: String
    let prerelease: Bool
    let publishedAt: Date
    let zipURL: URL
}

// MARK: - Implementation

final class GitHubReleaseListLoader: NSObject {
    enum Error: LocalizedError {
        case couldNotRetrieveVersions(String)
        case couldNotGetLatestTag(String)

        /// https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api
        /// The primary rate limit for unauthenticated requests is 60 requests per hour.
        private static let rateLimitRegex = #"(API rate limit exceeded for \d+\.\d+\.\d+\.\d+\.).*"#

        var errorDescription: String? {
            switch self {
            case let .couldNotRetrieveVersions(apiMessage):
                if let match = try? apiMessage.groups(regex: Error.rateLimitRegex), match.count == 2 {
                    return """
                    \(match[1])
                    \("🚑 Please try again in an hour.".yellow)
                    """
                }
                return apiMessage
            case let .couldNotGetLatestTag(apiMessage):
                return apiMessage
            }
        }
    }

    private let paths: GitHubUpdaterPaths

    private let latestTagRegex = #".*download/(.*)/.*"#
    private var lastRedirectionLocation: String?

    init(paths: GitHubUpdaterPaths) {
        self.paths = paths
    }

    // MARK: - Load Latest Tag

    /// https://docs.github.com/en/repositories/releasing-projects-on-github/linking-to-releases
    func loadLatestTag(architecture: GitHubUpdaterArchitecture) async throws -> String? {
        let binaryName = "\(architecture.rawValue).zip"
        let urlString = "https://github.com/\(paths.repositoryPath)/releases/latest/download/\(binaryName)"
        guard let url = URL(string: urlString) else {
            fatalError("Couldn't build url.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        _ = try await URLSession.shared.data(from: url, delegate: self)
        if let match = try lastRedirectionLocation?.groups(regex: latestTagRegex), match.count == 2 {
            return match[1]
        }
        return nil
    }

    // MARK: - Load Releases

    func load(count: Int, architecture: GitHubUpdaterArchitecture) async throws -> [Release] {
        let data = try await loadReleases(count: count)
        let releases = try parseRelease(data, architecture: architecture)
        return releases
    }

    private func loadReleases(count: Int) async throws -> Data {
        let releasesListURL = "https://api.github.com/repos/\(paths.repositoryPath)/releases"
        guard var components = URLComponents(string: releasesListURL) else {
            fatalError("Couldn't create url components.")
        }
        components.queryItems = [
            URLQueryItem(name: "per_page", value: count.description)
        ]
        guard let url = components.url else {
            fatalError("Couldn't build url.")
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse, (400 ..< 500) ~= httpResponse.statusCode {
            let errorModel = try parseError(data)
            throw Error.couldNotRetrieveVersions(errorModel.message)
        }
        return data
    }

    private func parseError(_ data: Data) throws -> ReleaseResponseErrorModel {
        let decoder = JSONDecoder()
        let model = try decoder.decode(ReleaseResponseErrorModel.self, from: data)
        return model
    }

    private func parseRelease(_ data: Data, architecture: GitHubUpdaterArchitecture) throws -> [Release] {
        let decoder = JSONDecoder()
        let model = try decoder.decode([ReleaseResponseModel].self, from: data)
        let formatter = ISO8601DateFormatter()
        return model.compactMap { release in
            guard let asset = release.assets.first(where: { $0.name == "\(architecture.rawValue).zip" }),
                  let zipURL = URL(string: asset.browser_download_url),
                  let publishedAt = formatter.date(from: release.published_at)
            else { return nil }
            return Release(name: release.name,
                           version: release.tag_name,
                           prerelease: release.prerelease,
                           publishedAt: publishedAt,
                           zipURL: zipURL)
        }
    }
}

extension GitHubReleaseListLoader: URLSessionTaskDelegate {
    func urlSession(
        _: URLSession,
        task _: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest _: URLRequest
    ) async -> URLRequest? {
        lastRedirectionLocation = response.allHeaderFields["Location"] as? String
        return nil
    }
}

// swiftlint:disable identifier_name
private struct ReleaseResponseModel: Decodable {
    struct Asset: Decodable {
        let name: String
        let browser_download_url: String
    }

    let name: String
    let tag_name: String
    let prerelease: Bool
    let published_at: String
    let assets: [Asset]
}

private struct ReleaseResponseErrorModel: Decodable {
    let message: String
}

// swiftlint:enable identifier_name
