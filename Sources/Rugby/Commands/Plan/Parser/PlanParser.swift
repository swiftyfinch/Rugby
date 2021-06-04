//
//  PlanParser.swift
//  
//
//  Created by Vyacheslav Khorkov on 24.04.2021.
//

import ArgumentParser
import Files
import Foundation
import Yams

struct PlanParser {
    struct Plan {
        let name: String
        let commands: [Command]
    }

    func parsePlans() throws -> [Plan] {
        guard let plansFile = try? Folder.current.file(at: .plans) else { return [] }

        let yml = try plansFile.readAsString()
        guard let rootArray = try Yams.load(yaml: yml) as? [[String: [[String: Any]]]] else {
            throw PlanError.incorrectYMLFormat
        }

        return try rootArray.reduce(into: []) { plans, planDictionary in
            for (plan, commands) in planDictionary {
                let commands = try commands.map(parseCommand)
                plans.append(Plan(name: plan, commands: commands))
            }
        }
    }
}

extension PlanParser {
    private enum Commands: String {
        case cache, focus, drop, shell
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
            let yml = try JSONDecoder().decode(ShellDecodable.self, from: dataArguments)
            return Shell(run: yml.run, verbose: yml.verbose ?? 0)
        }
    }
}
