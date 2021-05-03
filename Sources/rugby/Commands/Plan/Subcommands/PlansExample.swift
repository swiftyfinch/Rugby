//
//  PlansExample.swift
//  
//
//  Created by Vyacheslav Khorkov on 03.05.2021.
//

import ArgumentParser
import Files
import Foundation

enum PlansExampleError: Error, LocalizedError {
    case alreadyExists

    var errorDescription: String? {
        switch self {
        case .alreadyExists:
            return "\(String.plans.yellow) already exists."
        }
    }
}

struct PlansExample: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "example",
        abstract: "Generate example \(String.plans.yellow)"
    )

    func run() throws {
        guard (try? Folder.current.file(at: .plans)) == nil else {
            throw PlansExampleError.alreadyExists
        }

        let plansFile = try Folder.current.createFile(at: .plans)
        try plansFile.write("""
        # The first plan in file always run by default.
        - usual:
          # The first command without arguments like: rugby cache
          - command: cache
          # The second command: rugby drop "Test"
          - command: drop
            targets:
              - Test
          # And so on: rugby drop -i "TestProject" -p TestProject/TestProject.xcodeproj
          - command: drop
            targets:
              - TestProject$
            invert: true
            project: TestProject/TestProject.xcodeproj

        # Also, you can use custom plan: rugby --plan unit
        - unit:
          - command: cache
            # Alternative syntax for yml arrays:
            exclude: [Alamofire]
          - command: drop
            targets: [Test]
        """)
    }
}
