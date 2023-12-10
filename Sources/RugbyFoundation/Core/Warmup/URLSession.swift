import Foundation

// MARK: - Interface

protocol IURLSession: AnyObject {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func download(for request: URLRequest) async throws -> URL
}

// MARK: - Implementation

extension URLSession: IURLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }

    func download(for request: URLRequest) async throws -> URL {
        try await download(for: request, delegate: nil).0
    }
}
