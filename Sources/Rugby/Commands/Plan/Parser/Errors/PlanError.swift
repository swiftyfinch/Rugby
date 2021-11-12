//
//  PlanError.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

enum PlanError: Error, LocalizedError {
    case incorrectYMLFormat
    case incorrectCommandName
    case incorrectArgument
    case cantFindPlan(String)

    var errorDescription: String? {
        switch self {
        case .incorrectYMLFormat:
            return "Incorrect format in plans.yml."
        case .incorrectCommandName:
            return "Incorrect command name in plans.yml."
        case .incorrectArgument:
            return "Incorrect arguments in plans.yml."
        case .cantFindPlan(let plan):
            return "Couldn't find ✈️ \(plan) plan."
        }
    }
}
