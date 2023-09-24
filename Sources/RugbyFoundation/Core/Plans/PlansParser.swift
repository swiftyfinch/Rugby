//
//  PlansParser.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 09.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Fish
import Foundation
import Yams

// MARK: - Interface

/// The protocol describing a service to parse YAML files with Rugby plans.
public protocol IPlansParser {
    /// Returns the first plan from file at a path.
    /// - Parameter path: A path to plans file.
    func top(path: String) throws -> Plan

    /// Returns a plan with the name.
    /// - Parameters:
    ///   - name: A name of plan to find.
    ///   - path: A path to plans file.
    func named(_ name: String, path: String) throws -> Plan
}

/// The Rugby plan structure.
public struct Plan {
    /// The model of commands in the plan.
    public struct Command {
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
    private var cache: [String: [Plan]] = [:]
    private let topPlanRegex = #"^([\w-]+)(?=:)"#
    private let parsers: [FieldParser] = [
        StringFieldParser(),
        BoolFieldParser(),
        IntFieldParser(),
        StringsFieldParser()
    ]

    // MARK: - Methods

    private func parse(path: String) throws -> [Plan] {
        if let cachedPlans = cache[path] { return cachedPlans }

        let content = try File.read(at: path)
        let firstPlan = try parseTopPlan(content)

        let yaml = try Yams.load(yaml: content)
        guard let rawPlans = yaml as? [String: [RawCommand]] else {
            throw Error.incorrectFormat
        }

        // Bubbling up the 1st plan
        let sortedPlans = rawPlans.sorted { lhs, _ in lhs.key == firstPlan }
        let plans = try sortedPlans.compactMap { name, commands in
            try Plan(name: name, commands: commands.compactMap(parseCommand))
        }
        cache[path] = plans
        return plans
    }

    private func parseTopPlan(_ content: String) throws -> String {
        let groups = try content.groups(regex: topPlanRegex)
        guard let firstPlan = groups.first else { throw Error.noPlans }
        return firstPlan
    }

    private func parseCommand(_ command: RawCommand) throws -> Plan.Command {
        guard let commandName = command[.commandKey] as? String else {
            throw Error.missedCommandType
        }

        let args: [String] = try command.reduce(into: []) { args, field in
            guard field.key != .commandKey else { return }
            guard parsers.contains(where: { $0.parse(field.value, ofField: field.key, toArgs: &args) }) else {
                throw Error.unknownArgumentType(field.value)
            }
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

private protocol FieldParser {
    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) -> Bool
}

private struct StringFieldParser: FieldParser {
    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) -> Bool {
        guard let string = value as? String else { return false }
        if field == .argumentKey {
            args.insert(string, at: 0)
        } else {
            args.append("\(String.optionPrefix)\(field)")
            args.append(string)
        }
        return true
    }
}

private struct BoolFieldParser: FieldParser {
    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) -> Bool {
        guard let bool = value as? Bool else { return false }
        if bool {
            args.append("\(String.optionPrefix)\(field)")
        }
        return true
    }
}

private struct IntFieldParser: FieldParser {
    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) -> Bool {
        guard let int = value as? Int else { return false }
        args.append("\(String.optionPrefix)\(field)")
        args.append(String(int))
        return true
    }
}

private struct StringsFieldParser: FieldParser {
    func parse(_ value: Any, ofField field: String, toArgs args: inout [String]) -> Bool {
        guard let strings = value as? [String] else { return false }
        guard strings.isNotEmpty else { return true }
        if field == .argumentKey {
            args.insert(contentsOf: strings, at: 0)
        } else {
            args.append("\(String.optionPrefix)\(field)")
            args.append(contentsOf: strings)
        }
        return true
    }
}

// MARK: - IPlansParser

extension PlansParser: IPlansParser {
    public func top(path: String) throws -> Plan {
        let plans = try parse(path: path)
        guard let plan = plans.first else {
            throw Error.noPlans
        }
        return plan
    }

    public func named(_ name: String, path: String) throws -> Plan {
        let plans = try parse(path: path)
        guard let plan = plans.first(where: { $0.name == name }) else {
            throw Error.noPlanWithName(name)
        }
        return plan
    }
}
