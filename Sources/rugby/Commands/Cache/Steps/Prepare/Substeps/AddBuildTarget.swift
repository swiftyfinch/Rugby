//
//  AddBuildTarget.swift
//  
//
//  Created by Vyacheslav Khorkov on 10.04.2021.
//

import XcodeProj

extension CacheSubstepFactory {
    struct AddBuildTarget: Step {
        struct Input {
            let target: String
            let project: XcodeProj
            let dependencies: Set<String>
        }

        let progress: Printer
        let command: Cache

        func run(_ input: Input) throws {
            progress.print(input.dependencies, text: "Build targets")

            progress.print("Add build target: ".yellow + input.target, level: .vv)
            input.project.addTarget(name: input.target, dependencies: input.dependencies)

            progress.print("Save project ⏱".yellow, level: .vv)
            try input.project.write(pathString: .podsProject, override: true)
        }
    }
}
