//
//  PlansList.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.10.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Files
import Foundation

private enum PlansListError: Error, LocalizedError {
    case noPlans
    case incorrectPlanIndex

    var errorDescription: String? {
        switch self {
        case .noPlans:
            return """
            \(String.plans.red + " doesn't exist.".red)
            \("🚑 You can call \("example".white) subcommand to create one".yellow)
            """
        case .incorrectPlanIndex:
            return "You chose the wrong one"
        }
    }
}

struct PlansList: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Print all plans and select one if needed"
    )

    func run() throws {
        guard let plans = try? PlanParser().parsePlans(), !plans.isEmpty else {
            throw PlansListError.noPlans
        }

        var output = plans.enumerated()
            .compactMap { index, plan in
                "\(index + 1)) "
                    + plan.name.yellow
                    + (plan.description.map { " # " + $0 } ?? "").dim
            }
            .joined(separator: "\n")
        output += "\n0) " + "Cancel".yellow
        output += "\nWhich plan do you want to run?".green
        print(output)

        if let planIndex = readLine().flatMap(Int.init) {
            guard planIndex != 0 else { return }
            guard plans.indices ~= planIndex - 1 else {
                throw PlansListError.incorrectPlanIndex
            }

            var plansCommand = Plans()
            plansCommand.plan = plans[planIndex - 1].name
            try plansCommand.runPlans(plans)
        }
    }
}
