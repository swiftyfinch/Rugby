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
        case cache, drop
    }

    private func parseCommand(_ dictionary: [String: Any]) throws -> Command {
        guard let command = dictionary["command"] as? String, let commandName = Commands(rawValue: command) else {
            throw PlanError.incorrectCommandName
        }

        let dataArguments = try JSONSerialization.data(withJSONObject: dictionary)
        switch commandName {
        case .cache:
            let yml = try JSONDecoder().decode(CacheDecodable.self, from: dataArguments)
            var cache = Cache()
            cache.arch = yml.arch
            cache.sdk = yml.sdk ?? .sim
            cache.keepSources = yml.keepSources ?? false
            cache.exclude = yml.exclude ?? []
            cache.hideMetrics = yml.hideMetrics ?? false
            cache.ignoreCache = yml.ignoreCache ?? false
            cache.skipParents = yml.skipParents ?? false
            cache.verbose = yml.verbose ?? false
            return cache
        case .drop:
            let yml = try JSONDecoder().decode(DropDecodable.self, from: dataArguments)
            var drop = Drop()
            drop.targets = yml.targets ?? []
            drop.invert = yml.invert ?? false
            drop.project = yml.project ?? .podsProject
            drop.testFlight = yml.testFlight ?? false
            drop.keepSources = yml.keepSources ?? false
            drop.exclude = yml.exclude ?? []
            drop.hideMetrics = yml.hideMetrics ?? false
            drop.verbose = yml.verbose ?? false
            return drop
        }
    }
}
