//
//  Doctor.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 03.06.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser

struct Doctor: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        abstract: "• Show troubleshooting suggestions."
    )

    private static let output = """
    🚑 \("Doctor:".green) If you encourage any problems, please follow this checklist:
    1. Firstly, update Rugby to the last version;
    2. Run \("rugby --ignore-checksums".yellow);
    3. Try to investigate build logs yourself;
    4. Run \("rugby clean && rugby --ignore-checksums".yellow);
    5. Check that Pods project builds successfully without Rugby.

    Report an issue in GitHub discussions or any convenience support channel.
    Attach last files from \(".rugby/history".yellow) folder.
    But be sure that there are \("no sensitive".red) data.
    """

    func run() throws {
        print(Doctor.output)
    }
}
