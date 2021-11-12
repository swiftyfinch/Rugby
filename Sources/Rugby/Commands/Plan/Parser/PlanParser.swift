//
//  PlanParser.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 24.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Files
import Foundation
import Yams

struct PlanParser {
    struct Plan {
        let name: String
        let description: String?
        let commands: [Command]
    }

    func parsePlans() throws -> [Plan] {
        guard let plansFile = try? Folder.current.file(at: .plans) else { return [] }

        let yml = try plansFile.readAsString()
        guard let rootArray = try Yams.load(yaml: yml) as? [[String: [[String: Any]]]] else {
            throw PlanError.incorrectYMLFormat
        }

        let lines = yml.components(separatedBy: "\n")
        return try rootArray.reduce(into: []) { plans, planDictionary in
            for (plan, commands) in planDictionary {
                let description = parseDescription(plan: plan, lines: lines)
                let commands = try commands.map(parseCommand)
                plans.append(Plan(name: plan, description: description, commands: commands))
            }
        }
    }
}

extension PlanParser {
    private enum Commands: String {
        case cache, focus, drop, shell, plans
    }

    private func parseCommand(_ dictionary: [String: Any]) throws -> Command {
        guard let command = dictionary["command"] as? String, let commandName = Commands(rawValue: command) else {
            throw PlanError.incorrectCommandName
        }

        let dataArguments = try JSONSerialization.data(withJSONObject: dictionary)
        switch commandName {
        case .cache:
            let decodable = try JSONDecoder().decode(CacheDecodable.self, from: dataArguments)
            return Cache(from: decodable)
        case .focus:
            let decodable = try JSONDecoder().decode(FocusDecodable.self, from: dataArguments)
            return Focus(from: decodable)
        case .drop:
            let decodable = try JSONDecoder().decode(DropDecodable.self, from: dataArguments)
            return Drop(from: decodable)
        case .shell:
            let decodable = try JSONDecoder().decode(ShellDecodable.self, from: dataArguments)
            return Shell(from: decodable)
        case .plans:
            let decodable = try JSONDecoder().decode(PlansDecodable.self, from: dataArguments)
            return PlansReference(from: decodable)
        }
    }

    private func parseDescription(plan: String, lines: [String]) -> String? {
        let planName = "- \(plan):"
        guard let planIndex = lines.firstIndex(of: planName), lines.indices ~= planIndex - 1 else { return nil }

        let lineAbovePlan = lines[planIndex - 1]
        guard lineAbovePlan.hasPrefix("#") else { return nil }
        return String(lineAbovePlan.dropFirst().trimmingCharacters(in: [" "]))
    }
}
