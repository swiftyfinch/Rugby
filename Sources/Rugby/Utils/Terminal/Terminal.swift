//
//  Terminal.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 20.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

enum Terminal {
    static func columns() -> Int? {
        var windowSize = winsize()
        guard ioctl(1, UInt(TIOCGWINSZ), &windowSize) == 0 else { return nil }
        return Int(windowSize.ws_col)
    }

    static func isNoneTerminalOutput() -> Bool {
        isatty(STDOUT_FILENO) != 1
    }
}
