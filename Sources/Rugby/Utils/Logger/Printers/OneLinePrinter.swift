//
//  OneLinePrinter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 17.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import RugbyFoundation

// MARK: - Implementation

final class OneLinePrinter {
    private let maxLevel: Int
    private let columns: Int

    init(maxLevel: Int, columns: Int) {
        self.maxLevel = maxLevel
        self.columns = columns
    }
}

// MARK: - Printer

extension OneLinePrinter: Printer {
    func canPrint(level: Int) -> Bool { level <= maxLevel }

    func print(_ text: String, level: Int, updateLine: Bool) {
        guard canPrint(level: level) else { return }
        let choppedText = text.rainbowWidth(columns)
        Swift.print(updateLine ? "\u{1B}[1A\u{1B}[K\(choppedText)" : choppedText)
    }
}
