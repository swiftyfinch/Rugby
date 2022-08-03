//
//  PlansReference.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 12.11.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct PlansReference {
    let name: String
    let quiet = false
    let nonInteractive = false
}

extension PlansReference: Command {
    mutating func run(logFile: File) throws -> Metrics? {
        fatalError("This method must be never called.")
    }
}
