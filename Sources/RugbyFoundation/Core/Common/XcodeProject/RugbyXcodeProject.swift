import Foundation

// MARK: - Interface

enum RugbyError: LocalizedError {
    case alreadyUseRugby

    var errorDescription: String? {
        switch self {
        case .alreadyUseRugby:
            return "The project is already using 🏈 Rugby.\n".red
                + "🚑 Call \(#""rugby rollback""#) or \(#""pod install""#).".yellow
        }
    }
}

protocol IRugbyXcodeProject: AnyObject {
    func isAlreadyUsingRugby() async throws -> Bool
    func markAsUsingRugby() async throws
}

// MARK: - Implementation

final class RugbyXcodeProject {
    private let xcodeProject: IInternalXcodeProject
    private let yes = "YES"

    init(xcodeProject: IInternalXcodeProject) {
        self.xcodeProject = xcodeProject
    }
}

extension RugbyXcodeProject: IRugbyXcodeProject {
    func isAlreadyUsingRugby() async throws -> Bool {
        try await xcodeProject.contains(buildSettingsKey: .rugbyPatched)
    }

    func markAsUsingRugby() async throws {
        try await xcodeProject.set(buildSettingsKey: .rugbyPatched, value: yes)
    }
}

private extension String {
    static let rugbyPatched = "RUGBY_PATCHED"
}
