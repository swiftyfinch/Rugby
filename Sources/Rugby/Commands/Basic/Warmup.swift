import ArgumentParser
import Fish
import Foundation
import RugbyFoundation

extension ArchiveType: ExpressibleByArgument {}
struct Warmup: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "warmup",
        abstract: "Download remote binaries for targets from Pods project.",
        discussion: """
        \(Links.commandsHelp("warmup.md"))
        \(Links.docs("remote-cache.md"))
        """
    )

    @Argument(help: "Endpoint for your binaries storage (s3.eu-west-2.amazonaws.com).")
    var endpoint: String?

    @Flag(help: "Run only in analyse mode without downloading. The endpoint is optional.")
    var analyse = false

    @OptionGroup
    var buildOptions: BuildOptions

    @OptionGroup
    var commonOptions: CommonOptions

    @Option(help: "Timeout for requests in seconds.")
    var timeout = settings.warmupTimeout

    @Option(help: "The maximum number of simultaneous connections.")
    var maxConnections = settings.warmupMaximumConnectionsPerHost

    @Option(help: "Extra HTTP header fields for a request (\"s3-key: my-secret-key\").")
    var headers: [String] = []

    @Option(help: "Binary archive file type to use: zip or 7z.")
    var archiveType: RugbyFoundation.ArchiveType = .zip

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.logLevel)
    }
}

// MARK: - Body

extension Warmup: RunnableCommand {
    enum Error: LocalizedError {
        case missingEndpoint

        var errorDescription: String? {
            switch self {
            case .missingEndpoint:
                return "Missing endpoint."
            }
        }
    }

    func body() async throws {
        let mode: WarmupMode
        switch (buildOptions.targetsOptions.tryMode, analyse, endpoint) {
        case (true, _, _):
            mode = .printTargets
        case (_, true, let endpoint):
            mode = .analyse(endpoint: endpoint)
        case (_, false, let endpoint?):
            mode = .endpoint(endpoint)
        case (_, false, nil):
            throw Error.missingEndpoint
        }
        let warmupManager = dependencies.warmupManager(
            timeoutIntervalForRequest: TimeInterval(timeout),
            httpMaximumConnectionsPerHost: maxConnections,
            archiveType: archiveType
        )
        try await warmupManager.warmup(
            mode: mode,
            targetsOptions: buildOptions.targetsOptions.foundation(),
            options: buildOptions.xcodeBuildOptions(),
            maxInParallel: maxConnections,
            headers: headers.parseHeaders(),
            fileExtension: archiveType.fileExtension
        )
    }
}

extension [String] {
    func parseHeaders() -> [String: String] {
        reduce(into: [:]) { headers, header in
            let fieldAndValue = header.components(separatedBy: ": ")
            guard fieldAndValue.count == 2 else { return }
            let (field, value) = (fieldAndValue[0], fieldAndValue[1])
            headers[field] = value
        }
    }
}
