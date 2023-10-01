import Fish
import Foundation
import Zip

final class CacheDownloader: Loggable {
    let logger: ILogger
    private let reachabilityChecker: ReachabilityChecker
    private let urlSession: URLSession

    init(logger: ILogger,
         reachabilityChecker: ReachabilityChecker,
         urlSession: URLSession) {
        self.logger = logger
        self.reachabilityChecker = reachabilityChecker
        self.urlSession = urlSession
        Zip.addCustomFileExtension("tmp")
    }

    // MARK: - Internal

    func checkIfBinaryIsReachable(url: URL) async -> Bool {
        (try? await reachabilityChecker.checkIfURLIsReachable(url)) == true
    }

    func downloadBinary(url: URL, to folderURL: URL) async -> Bool {
        guard let fileURL = await download(url) else { return false }
        return await unzip(fileURL, to: folderURL)
    }

    // MARK: - Private

    private func download(_ url: URL) async -> URL? {
        do {
            await log("Downloading \(url)", output: .file)
            let urlRequest = URLRequest(url: url)
            return try await urlSession.download(for: urlRequest).0
        } catch {
            await log("Failed downloading \(url):\n\(error.beautifulDescription)", output: .file)
            return nil
        }
    }

    private func unzip(_ fileURL: URL, to folderURL: URL) async -> Bool {
        do {
            await log("Unzipping to \(folderURL.path)", output: .file)
            try Folder.create(at: folderURL.path)
            try Zip.unzipFile(fileURL, destination: folderURL, overwrite: true, password: nil)
            return true
        } catch {
            await log("Failed unzipping to \(folderURL.path):\n\(error.beautifulDescription)", output: .file)
            return false
        }
    }
}
