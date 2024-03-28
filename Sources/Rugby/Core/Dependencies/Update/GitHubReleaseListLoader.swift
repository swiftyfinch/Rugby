import Foundation

// MARK: - Interface

struct Release {
    let name: String
    let version: String
    let prerelease: Bool
    let publishedAt: Date
    let zipURL: URL
}

// MARK: - Implementation

final class GitHubReleaseListLoader {

    enum Error: LocalizedError {
        case couldNotRetrieveVersions(String)

        var errorDescription: String? {
            switch self {
            case .couldNotRetrieveVersions(let apiMessage):
                return apiMessage
            }
        }
    }
    private let paths: GitHubUpdaterPaths

    init(paths: GitHubUpdaterPaths) {
        self.paths = paths
    }

    func load(count: Int, architecture: GitHubUpdaterArchitecture) async throws -> [Release] {
        let data = try await loadData(count: count)
        let releases = try parseData(data, architecture: architecture)
        return releases
    }

    // MARK: - Private

    private func loadData(count: Int) async throws -> Data {
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
        if let httpResponse = response as? HTTPURLResponse, (400..<500) ~= httpResponse.statusCode {
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

    private func parseData(_ data: Data, architecture: GitHubUpdaterArchitecture) throws -> [Release] {
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
