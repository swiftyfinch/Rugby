import Fish
import Foundation
import Yams

// MARK: - Interface

/// The protocol describing a service to parse YAML files with Rugby plans.
public protocol IPlansParser: AnyObject {
    /// Returns plans list.
    /// - Parameter path: A path to plans file.
    func plans(atPath path: String) async throws -> [Plan]

    /// Returns the first plan from file at a path.
    /// - Parameter path: A path to plans file.
    func topPlan(atPath path: String) async throws -> Plan

    /// Returns a plan with the name.
    /// - Parameters:
    ///   - name: A name of plan to find.
    ///   - path: A path to plans file.
    func planNamed(_ name: String, path: String) async throws -> Plan
}

/// The Rugby plan structure.
public struct Plan: Equatable {
    /// The model of commands in the plan.
    public struct Command: Equatable {
        /// The command name.
        public let name: String
        /// The command arguments.
        public var args: [String]

        /// Initialization.
        /// - Parameters:
        ///   - name: The command name.
        ///   - args: The command arguments.
        public init(name: String, args: [String] = []) {
            self.name = name
            self.args = args
        }
    }

    /// The plan name.
    public let name: String
    /// The list of plan commands.
    public let commands: [Command]
}

enum PlansParserError: LocalizedError {
    case noPlans
    case noPlanWithName(String)
    case incorrectFormat
    case missedCommandType
    case unknownArgumentType(Any)

    var errorDescription: String? {
        let output: String
        switch self {
        case .noPlans:
            output = "Couldn't find any plans."
        case let .noPlanWithName(name):
            output = #"Couldn't find plan with name "\#(name)"."#
        case .incorrectFormat:
            output = "Incorrect plans format."
        case .missedCommandType:
            output = "Missed command type."
        case let .unknownArgumentType(type):
            output = #"Unknown argument type "\#(type)"."#
        }
        return output
    }
}

// MARK: - Implementation

final class PlansParser {
    private typealias Error = PlansParserError
    private typealias RawCommand = [String: Any]

    private let envVariablesResolver: IEnvVariablesResolver
    private var cache: [String: [Plan]] = [:]
    private let topPlanRegex = #"^([\w-]+)(?=:)"#
    private lazy var parsers: [FieldParser] = [
        StringFieldParser(envVariablesResolver: envVariablesResolver),
        BoolFieldParser(),
        IntFieldParser(),
        StringsFieldParser(envVariablesResolver: envVariablesResolver)
    ]

    init(envVariablesResolver: IEnvVariablesResolver) {
        self.envVariablesResolver = envVariablesResolver
    }

    // MARK: - Methods

    private func parse(path: String) async throws -> [Plan] {
        if let cachedPlans = cache[path] { return cachedPlans }

        let content = try File.read(at: path)
        let firstPlan = try parseTopPlan(content)

        let yaml = try Yams.load(yaml: content)
        guard let rawPlans = yaml as? [String: [RawCommand]] else {
            throw Error.incorrectFormat
        }

        // Bubbling up the 1st plan
        let sortedPlans = rawPlans.sorted { lhs, _ in lhs.key == firstPlan }
        var plans: [Plan] = []
        for (name, commands) in sortedPlans {
            var parsedCommands: [Plan.Command] = []
            for command in commands {
                try await parsedCommands.append(parseCommand(command))
            }
            plans.append(Plan(name: name, commands: parsedCommands))
        }
        cache[path] = plans
        return plans
    }

    private func parseTopPlan(_ content: String) throws -> String {
        let groups = try content.groups(regex: topPlanRegex)
        guard let firstPlan = groups.first else { throw Error.noPlans }
        return firstPlan
    }

    private func parseCommand(_ command: RawCommand) async throws -> Plan.Command {
        guard let commandName = command[.commandKey] as? String else {
            throw Error.missedCommandType
        }

        var args: [String] = []
        for key in command.keys.sorted() {
            guard let value = command[key], key != .commandKey else { continue }
            var parsed = false
            for parser in parsers {
                parsed = try await parser.parse(value, ofField: key, toArgs: &args)
                if parsed { break }
            }
            guard parsed else { throw Error.unknownArgumentType(value) }
        }
        return Plan.Command(name: commandName, args: args)
    }
}

// MARK: - Constants

private extension String {
    static let commandKey = "command"
    static let argumentKey = "argument"
    static let optionPrefix = "--"
}

// MARK: - Field Parsers

private protocol FieldParser: AnyObject {
    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) async throws -> Bool
}

private final class StringFieldParser: FieldParser {
    private let envVariablesResolver: IEnvVariablesResolver

    init(envVariablesResolver: IEnvVariablesResolver) {
        self.envVariablesResolver = envVariablesResolver
    }

    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) async throws -> Bool {
        guard let string = value as? String else { return false }
        let resolvedString = try await envVariablesResolver.resolve(string)
        if field == .argumentKey {
            args.insert(resolvedString, at: 0)
        } else {
            args.append("\(String.optionPrefix)\(field)")
            args.append(resolvedString)
        }
        return true
    }
}

private final class BoolFieldParser: FieldParser {
    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) -> Bool {
        guard let bool = value as? Bool else { return false }
        if bool {
            args.append("\(String.optionPrefix)\(field)")
        }
        return true
    }
}

private final class IntFieldParser: FieldParser {
    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) -> Bool {
        guard let int = value as? Int else { return false }
        args.append("\(String.optionPrefix)\(field)")
        args.append(String(int))
        return true
    }
}

private final class StringsFieldParser: FieldParser {
    private let envVariablesResolver: IEnvVariablesResolver

    init(envVariablesResolver: IEnvVariablesResolver) {
        self.envVariablesResolver = envVariablesResolver
    }

    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) async throws -> Bool {
        guard let strings = value as? [String] else { return false }
        guard strings.isNotEmpty else { return true }
        let resolvedStrings = try await strings.concurrentMap(envVariablesResolver.resolve)
        if field == .argumentKey {
            args.insert(contentsOf: resolvedStrings, at: 0)
        } else {
            args.append("\(String.optionPrefix)\(field)")
            args.append(contentsOf: resolvedStrings)
        }
        return true
    }
}

// MARK: - IPlansParser

extension PlansParser: IPlansParser {
    public func plans(atPath path: String) async throws -> [Plan] {
        try await parse(path: path)
    }

    public func topPlan(atPath path: String) async throws -> Plan {
        let plans = try await plans(atPath: path)
        guard let plan = plans.first else {
            throw Error.noPlans
        }
        return plan
    }

    public func planNamed(_ name: String, path: String) async throws -> Plan {
        let plans = try await plans(atPath: path)
        guard let plan = plans.first(where: { $0.name == name }) else {
            throw Error.noPlanWithName(name)
        }
        return plan
    }
}
