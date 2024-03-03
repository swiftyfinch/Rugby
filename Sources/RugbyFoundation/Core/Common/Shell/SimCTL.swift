import Foundation

// MARK: Interface

protocol ISimCTL: AnyObject {
    func availableDevices() throws -> [Device]
}

struct Device: Equatable {
    let udid: String
    let isAvailable: Bool
    let state: String
    let name: String
    let runtime: String
}

enum SimCTLError: LocalizedError {
    case nilOutput
    case unexpectedOutput

    var errorDescription: String? {
        switch self {
        case .nilOutput:
            return "The simctl command returned nil."
        case .unexpectedOutput:
            return "The simctl command returned an unexpected output."
        }
    }
}

// MARK: - Implementation

final class SimCTL {
    typealias Error = SimCTLError
    private let shellExecutor: IShellExecutor

    init(shellExecutor: IShellExecutor) {
        self.shellExecutor = shellExecutor
    }

    private func run(_ command: String) throws -> String {
        guard let output = try shellExecutor.throwingShell(command) else {
            throw Error.nilOutput
        }
        return output
    }
}

extension SimCTL: ISimCTL {
    func availableDevices() throws -> [Device] {
        let output = try run("xcrun simctl list devices available --json")
        guard
            let outputData = output.data(using: .utf8),
            let json = try JSONSerialization.jsonObject(with: outputData) as? [String: Any],
            let runtimesJSON = json["devices"] as? [String: Any]
        else { throw Error.unexpectedOutput }

        return runtimesJSON.flatMap { runtimeJSON -> [Device] in
            guard let devicesJSON = runtimeJSON.value as? [[String: Any]] else { return [] }
            return devicesJSON.compactMap { deviceJSON in
                guard
                    let udid = deviceJSON["udid"] as? String,
                    let isAvailable = deviceJSON["isAvailable"] as? Bool,
                    let state = deviceJSON["state"] as? String,
                    let name = deviceJSON["name"] as? String
                else { return nil }
                return Device(
                    udid: udid,
                    isAvailable: isAvailable,
                    state: state,
                    name: name,
                    runtime: runtimeJSON.key
                )
            }
        }
    }
}
