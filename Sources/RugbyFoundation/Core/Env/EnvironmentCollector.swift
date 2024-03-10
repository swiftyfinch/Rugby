import Fish
import Foundation

// MARK: - Interface

/// The protocol describing a service providing the environment information.
public protocol IEnvironmentCollector: AnyObject {
    /// Returns the environment information.
    /// - Parameters:
    ///   - rugbyVersion: The current version of Rugby.
    ///   - rugbyEnvironment: The variable names and values in the environment which is used by Rugby.
    func env(
        rugbyVersion: String,
        rugbyEnvironment: [String: String]
    ) async throws -> [String]

    /// Writes the environment information and the command description to a log file.
    /// - Parameters:
    ///   - rugbyVersion: The current version of Rugby.
    ///   - command: A command to log.
    ///   - rugbyEnvironment: The variable names and values in the environment which is used by Rugby.
    func write<Command>(
        rugbyVersion: String,
        command: Command,
        rugbyEnvironment: [String: String]
    ) async throws

    /// Logs Xcode version.
    func logXcodeVersion() async throws

    /// Logs the command description.
    /// - Parameter command: A command to log.
    func logCommandDump<Command>(command: Command) async
}

// MARK: - Implementation

final class EnvironmentCollector: Loggable {
    let logger: ILogger
    private let workingDirectory: IFolder
    private let shellExecutor: IShellExecutor
    private let swiftVersionProvider: ISwiftVersionProvider
    private let architectureProvider: IArchitectureProvider
    private let xcodeCLTVersionProvider: IXcodeCLTVersionProvider
    private let git: IGit

    init(logger: ILogger,
         workingDirectory: IFolder,
         shellExecutor: IShellExecutor,
         swiftVersionProvider: ISwiftVersionProvider,
         architectureProvider: IArchitectureProvider,
         xcodeCLTVersionProvider: IXcodeCLTVersionProvider,
         git: IGit) {
        self.logger = logger
        self.workingDirectory = workingDirectory
        self.shellExecutor = shellExecutor
        self.swiftVersionProvider = swiftVersionProvider
        self.architectureProvider = architectureProvider
        self.xcodeCLTVersionProvider = xcodeCLTVersionProvider
        self.git = git
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

    private func getProject() -> String {
        let projects = try? workingDirectory.folders().filter { folder in
            folder.pathExtension == "xcodeproj" || folder.pathExtension == "xcworkspace"
        }
        let project = projects?.first?.nameExcludingExtension
        return "Project: \(project ?? .unknown)"
    }

    private func getGitBranch() -> String {
        let branch = try? git.currentBranch()
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
        rugbyEnvironment: [String: String]
    ) async throws -> [String] {
        let xcodeCLTInfo = try xcodeCLTVersionProvider.version()
        let xcodeCLTVersion = xcodeCLTInfo.build.map { "\(xcodeCLTInfo.base) (\($0))" } ?? xcodeCLTInfo.base
        var output = try [
            "Rugby version: \(rugbyVersion)",
            await getSwiftVersion(),
            "CLT: \(xcodeCLTVersion)",
            getCPU(),
            getProject(),
            getGitBranch()
        ]
        rugbyEnvironment.keys.sorted().forEach { key in
            guard let value = rugbyEnvironment[key] else { return }
            output.append("\(key): \(value)")
        }
        return output
    }

    public func write(
        rugbyVersion: String,
        command: some Any,
        rugbyEnvironment: [String: String]
    ) async throws {
        var environment = try await env(
            rugbyVersion: rugbyVersion,
            rugbyEnvironment: rugbyEnvironment
        )
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
