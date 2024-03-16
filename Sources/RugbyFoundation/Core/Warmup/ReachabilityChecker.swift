import Foundation

// MARK: - Interface

protocol IReachabilityChecker: AnyObject {
    func checkIfURLIsReachable(_ url: URL, headers: [String: String]) async throws -> Bool
}

enum ReachabilityCheckerError: LocalizedError, Equatable {
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
    private let urlSession: IURLSession

    init(urlSession: IURLSession) {
        self.urlSession = urlSession
    }
}

extension ReachabilityChecker: IReachabilityChecker {
    private typealias Error = ReachabilityCheckerError

    func checkIfURLIsReachable(_ url: URL, headers: [String: String]) async throws -> Bool {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        headers.forEach { field, value in
            urlRequest.addValue(value, forHTTPHeaderField: field)
        }
        let (_, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = (response as? HTTPURLResponse) else { throw Error.urlUnreachable(url) }
        return httpResponse.statusCode == 200
    }
}
