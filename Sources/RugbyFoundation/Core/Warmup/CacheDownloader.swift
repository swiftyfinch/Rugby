import Fish
import Foundation

// MARK: - Interface

protocol ICacheDownloader: AnyObject {
    func checkIfBinaryIsReachable(url: URL) async -> Bool
    func downloadBinary(url: URL, to folderURL: URL) async -> Bool
}

// MARK: - Implementation

final class CacheDownloader: Loggable {
    let logger: ILogger
    private let reachabilityChecker: IReachabilityChecker
    private let urlSession: IURLSession
    private let decompressor: IDecompressor

    init(logger: ILogger,
         reachabilityChecker: IReachabilityChecker,
         urlSession: IURLSession,
         decompressor: IDecompressor) {
        self.logger = logger
        self.reachabilityChecker = reachabilityChecker
        self.urlSession = urlSession
        self.decompressor = decompressor
    }

    // MARK: - Private

    private func download(_ url: URL) async -> URL? {
        do {
            await log("Downloading \(url)", output: .file)
            let urlRequest = URLRequest(url: url)
            return try await urlSession.download(for: urlRequest)
        } catch {
            await log("Failed downloading \(url):\n\(error.beautifulDescription)", output: .file)
            return nil
        }
    }

    private func unzip(_ fileURL: URL, to folderURL: URL) async -> Bool {
        do {
            await log("Unzipping to \(folderURL.path)", output: .file)
            try Folder.create(at: folderURL.path)
            try decompressor.unzipFile(fileURL, destination: folderURL)
            return true
        } catch {
            await log("Failed unzipping to \(folderURL.path):\n\(error.beautifulDescription)", output: .file)
            return false
        }
    }
}

extension CacheDownloader: ICacheDownloader {
    func checkIfBinaryIsReachable(url: URL) async -> Bool {
        (try? await reachabilityChecker.checkIfURLIsReachable(url)) == true
    }

    func downloadBinary(url: URL, to folderURL: URL) async -> Bool {
        guard let fileURL = await download(url) else { return false }
        return await unzip(fileURL, to: folderURL)
    }
}
