import Foundation

// MARK: - Interface

public protocol IXcodeCLTVersionProvider: AnyObject {
    func version() throws -> XcodeVersion
}

/// Representation of an Xcode version
public struct XcodeVersion {
    let base: String
    let build: String?
}

extension XcodeVersion: CustomStringConvertible {
    public var description: String {
        "Xcode \(base) - Build version \(build ?? "unknown")"
    }
}

enum XcodeCLTVersionProviderError: LocalizedError {
    case unknownXcodeCLT

    public var errorDescription: String? {
        switch self {
        case .unknownXcodeCLT:
            return """
            \("Couldn't find Xcode CLT.".red)
            \("🚑 Check Xcode Preferences → Locations → Command Line Tools.".yellow)
            """
        }
    }
}

// MARK: - Implementation

final class XcodeCLTVersionProvider {
    private typealias Error = XcodeCLTVersionProviderError
    private let shellExecutor: IShellExecutor
    private var cachedXcodeVersion: XcodeVersion?

    init(shellExecutor: IShellExecutor) {
        self.shellExecutor = shellExecutor
    }
}

// MARK: - IXcodeCLTVersionProvider

extension XcodeCLTVersionProvider: IXcodeCLTVersionProvider {
    func version() throws -> XcodeVersion {
        if let cachedXcodeVersion { return cachedXcodeVersion }

        guard let output = try? shellExecutor.throwingShell("xcodebuild -version")?
            .components(separatedBy: .newlines)
            .filter({ !$0.isEmpty })
        else { throw XcodeCLTVersionProviderError.unknownXcodeCLT }

        let version: XcodeVersion
        if output.count == 2 {
            version = XcodeVersion(base: output[0], build: output[1])
        } else {
            version = XcodeVersion(base: output.joined(separator: " - "), build: nil)
        }
        cachedXcodeVersion = version
        return version
    }
}
