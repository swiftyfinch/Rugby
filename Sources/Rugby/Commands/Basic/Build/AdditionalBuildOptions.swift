//
//  AdditionalBuildOptions.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 18.02.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser

struct AdditionalBuildOptions: ParsableCommand {
    @Flag(name: .long, help: "Build without debug symbols.")
    var strip = false
}
