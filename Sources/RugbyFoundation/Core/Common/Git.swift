import Foundation

// MARK: - Interface

protocol IGit: AnyObject {
    func currentBranch() throws -> String?
    func hasUncommittedChanges() throws -> Bool
    func isBehind(branch: String) throws -> Bool
}

enum GitError: LocalizedError {
    case nilOutput

    var errorDescription: String? {
        switch self {
        case .nilOutput:
            return "The git command returned nil."
        }
    }
}

// MARK: - Implementation

final class Git {
    private let shellExecutor: IShellExecutor

    init(shellExecutor: IShellExecutor) {
        self.shellExecutor = shellExecutor
    }

    private func run(_ command: String) throws -> String {
        guard let output = try shellExecutor.throwingShell(command) else {
            throw GitError.nilOutput
        }
        return output
    }
}

// MARK: - IGit

extension Git: IGit {
    func currentBranch() throws -> String? {
        try run("git branch --show-current")
    }

    func hasUncommittedChanges() throws -> Bool {
        try run("git status --porcelain").isNotEmpty
    }

    func isBehind(branch: String) throws -> Bool {
        try run("git rev-list \(branch)...").isNotEmpty
    }
}
