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
    🚑 If you have any problems, please try these solutions.
    After each one, you need to repeat your usual workflow.

    1. Update 🏈 Rugby to the latest version:
       \("brew install rugby".yellow) or \("mint install rugby".yellow)
    2. Check that you're building the proper configuration.
       Sometimes projects don't have the default \("Debug".yellow) config.
       If so, you need to pass your custom config:
       \("rugby cache --config Your-Not-Debug-Config".yellow)
    2. Add ignore option \("rugby --ignore-checksums".yellow).
       Be careful, you can't pass this option to plans command this way.
       More info here: \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Plans.md".cyan).
                       (⌘ + double click on the link);
    3. Try \("rugby clean".yellow) before repeating your usual workflow;
    4. Try to clean up your \("DerivedData".yellow) and use \("rugby clean".yellow) together;
    5. Check that Pods project builds successfully without 🏈 Rugby.

    By the way, you can try to investigate build logs by yourself:
    \(".rugby/rugby.log".yellow)
    \(".rugby/build.log".yellow)
    \(".rugby/rawBuild.log".yellow)
    and more there \(".rugby/history".yellow)

    Report an issue in GitHub or by any convenient support channel.
    Attach last files from \(".rugby/history".yellow) folder.
    But be sure that there are \("no sensitive".red) data.
    """

    func run() throws {
        print(Doctor.output)
    }
}
