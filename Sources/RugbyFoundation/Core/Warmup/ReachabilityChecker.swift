import Foundation

enum ReachabilityCheckerError: LocalizedError {
    case urlUnreachable(URL)

    var errorDescription: String? {
        switch self {
        case let .urlUnreachable(url):
            return "\(url) unreachable."
        }
    }
}

// MARK: - Implementation

final class ReachabilityChecker {
    private typealias Error = ReachabilityCheckerError

    func checkIfURLIsReachable(_ url: URL) async throws -> Bool {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = (response as? HTTPURLResponse) else { throw Error.urlUnreachable(url) }
        return httpResponse.statusCode == 200
    }
}
