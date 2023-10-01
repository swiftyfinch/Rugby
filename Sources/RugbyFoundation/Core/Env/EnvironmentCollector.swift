import Fish
import Foundation

// MARK: - Interface

/// The protocol describing a service providing the environment information.
public protocol IEnvironmentCollector {
    /// Returns the environment information.
    /// - Parameters:
    ///   - rugbyVersion: The current version of Rugby.
    ///   - workingDirectory: A directory with Pods folder.
    func env(rugbyVersion: String, workingDirectory: IFolder) async throws -> [String]

    /// Writes the environment information and the command description to a log file.
    /// - Parameters:
    ///   - rugbyVersion: The current version of Rugby.
    ///   - command: A command to log.
    ///   - workingDirectory: A directory with Pods folder.
    func write<Command>(rugbyVersion: String, command: Command, workingDirectory: IFolder) async throws

    /// Logs Xcode version.
    func logXcodeVersion() async throws

    /// Logs the command description.
    /// - Parameter command: A command to log.
    func logCommandDump<Command>(command: Command) async
}

// MARK: - Implementation

final class EnvironmentCollector: Loggable {
    let logger: ILogger
    private let shellExecutor: IShellExecutor
    private let swiftVersionProvider: ISwiftVersionProvider
    private let architectureProvider: IArchitectureProvider
    private let xcodeCLTVersionProvider: IXcodeCLTVersionProvider

    init(logger: ILogger,
         shellExecutor: IShellExecutor,
         swiftVersionProvider: ISwiftVersionProvider,
         architectureProvider: IArchitectureProvider,
         xcodeCLTVersionProvider: IXcodeCLTVersionProvider) {
        self.logger = logger
        self.shellExecutor = shellExecutor
        self.swiftVersionProvider = swiftVersionProvider
        self.architectureProvider = architectureProvider
        self.xcodeCLTVersionProvider = xcodeCLTVersionProvider
    }

    // MARK: - Private

    private func getSwiftVersion() async throws -> String {
        let version = try await swiftVersionProvider.swiftVersion()
        return "Swift: \(version)"
    }

    private func getCPU() -> String {
        let cpu = (try? shellExecutor.throwingShell("sysctl -n machdep.cpu.brand_string")) ?? .unknown
        return "CPU: \(cpu.trimmingCharacters(in: .newlines)) (\(architectureProvider.architecture().rawValue))"
    }

    private func getProject(workingDirectory: IFolder) -> String {
        let projects = try? workingDirectory.folders().filter { folder in
            folder.pathExtension == "xcodeproj" || folder.pathExtension == "xcworkspace"
        }
        let project = projects?.first?.nameExcludingExtension
        return "Project: \(project ?? .unknown)"
    }

    private func getGitBranch() -> String {
        let branch = try? shellExecutor.throwingShell("git branch --show-current")?
            .trimmingCharacters(in: .newlines)
        return "Git branch: \(branch ?? .unknown)"
    }

    private func getCommandDump(command: some Any) -> String {
        let commandDump = "\(command)".replacingOccurrences(of: "\\b_", with: "", options: .regularExpression)
        return "Command dump: \(commandDump)"
    }
}

private extension String {
    static let unknown = "Unknown"
}

// MARK: - IEnvironmentCollector

extension EnvironmentCollector: IEnvironmentCollector {
    public func env(
        rugbyVersion: String,
        workingDirectory: IFolder
    ) async throws -> [String] {
        let xcodeCLTInfo = try xcodeCLTVersionProvider.version()
        let xcodeCLTVersion = xcodeCLTInfo.build.map { "\(xcodeCLTInfo.base) (\($0))" } ?? xcodeCLTInfo.base
        return try [
            "Rugby version: \(rugbyVersion)",
            await getSwiftVersion(),
            "CLT: \(xcodeCLTVersion)",
            getCPU(),
            getProject(workingDirectory: workingDirectory),
            getGitBranch()
        ]
    }

    public func write(rugbyVersion: String, command: some Any, workingDirectory: IFolder) async throws {
        var environment = try await env(rugbyVersion: rugbyVersion, workingDirectory: workingDirectory)
        environment.append(getCommandDump(command: command))
        for value in environment {
            await log(value, output: .file)
        }
    }

    public func logXcodeVersion() async throws {
        try await log("CLT: \(xcodeCLTVersionProvider.version().base)")
    }

    public func logCommandDump(command: some Any) async {
        await log(getCommandDump(command: command), output: .file)
    }
}
