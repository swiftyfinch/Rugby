//
//  Rainbow+WordWrappedLines.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.11.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension String {
    func wordWrappedLines(width: Int) -> [String] {
        guard !isEmpty else { return [self] }

        let words = rainbowSplit().components(separatedBy: .whitespaces)
        var lines: [String] = []
        var buffer = ""
        words.enumerated().forEach { index, word in
            if buffer.raw.count + word.raw.count > width {
                lines.append(buffer)
                buffer = ""
            }

            buffer += word
            if index + 1 != words.count {
                buffer.append(" ")
            }
        }
        if !buffer.isEmpty {
            lines.append(buffer)
        }
        return lines
    }
}
