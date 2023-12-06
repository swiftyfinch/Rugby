import Foundation

// MARK: - Interface

protocol IURLSession: AnyObject {
    func download(for request: URLRequest) async throws -> URL
}

// MARK: - Implementation

extension URLSession: IURLSession {
    func download(for request: URLRequest) async throws -> URL {
        try await download(for: request).0
    }
}
