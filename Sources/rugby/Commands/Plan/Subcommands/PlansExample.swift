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
            return """
            \(String.plans.red + " already exists.".red)
            \("🚑 You can find example here".yellow) (⌘ + double click on link)
            \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Plans.md#-generate-example".cyan)
            """
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
        try plansFile.write(Self.template)
        print("🏈 Example file was saved at ".green + ".rugby/plans.yml".yellow)
        print("Also, you can find example here: (⌘ + double click on link)")
        print("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Plans.md#-generate-example".cyan)
    }

    private static let template: String = """
        # You can find more information here:
        # https://github.com/swiftyfinch/Rugby/blob/main/Docs/Plans.md

        # The first plan in the file always run by default
        - usual:
          # 🐚 Optionally you can generate project if you use Xcodegen or something like that
          #- command: shell
          #  run: xcodegen

          # 🐚 Also, you can install pods before each rugby call right here
          - command: shell
            run: bundle exec pod install # Or you can use any shell command
            verbose: false

          # 🏈 The first Rugby command without arguments like: $ rugby cache
          - command: cache
            # Optional parameters with default values:
            #graph: false
            #arch: null # By default x86_64 if sdk == sim
            #sdk: sim
            #keepSources: false
            #exclude: []
            #hideMetrics: false
            #ignoreChecksums: false
            #verbose: false

          # 🗑 The second command: $ rugby drop "Test"
          - command: drop
            targets:
              - Test
            exclude: # Optional
              - Pods-TestProject # It's just for example
            # Optional parameters with default values:
            invert: false
            project: "Pods/Pods.xcodeproj"
            testFlight: false
            keepSources: false
            hideMetrics: false
            verbose: false

          # 🗑 And so on: $ rugby drop -i "TestProject" -p TestProject/TestProject.xcodeproj
          - command: drop
            targets:
              - ^TestProject$
            invert: true
            project: TestProject/TestProject.xcodeproj


        # Also, you can use another custom plan: $ rugby --plan unit
        - unit:
          - command: cache
            exclude: [Alamofire]
          - command: drop
            targets: [Test]
            exclude: [MyFeatureTests]
        """
}
