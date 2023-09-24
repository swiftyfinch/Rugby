//
//  BoxPainter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.11.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import RugbyFoundation

final class BoxPainter {
    private static let verticalBorder = "│"
    private let leftBorder = "\(verticalBorder) "
    private let rightBorder = " \(verticalBorder)"
    private let horizontalBorder = "─"
    private let topLeftCorner = "╭"
    private let topRightCorner = "╮"
    private let bottomLeftCorner = "╰"
    private let bottomRightCorner = "╯"

    func drawTable(_ lines: [(left: String, right: String)],
                   separator: String,
                   terminalWidth: Int) -> String? {
        guard !lines.isEmpty else { return nil }

        guard let leftWidth = lines.max(by: { $0.left.rawCount < $1.left.rawCount })?.left.rawCount
        else { return nil }

        var wrappedLines: [(left: String, rights: [String])] = []
        let terminalRight = terminalWidth - leftBorder.rawCount - leftWidth - separator.rawCount - rightBorder.rawCount
        for line in lines {
            let rightLines = line.right.wordWrappedLines(width: terminalRight - 2).enumerated().map { index, line in
                var edittedLine = ""
                if index == 0 {
                    edittedLine = "\("*".accent) \(line)"
                } else {
                    edittedLine = "  \(line)"
                }
                return edittedLine.hasSuffix(" ") ? String(edittedLine.dropLast()) : edittedLine
            }
            wrappedLines.append((line.left, rightLines))
        }

        guard let maxRightWidth = wrappedLines.flatMap({ $0.rights }).max(by: { $0.rawCount < $1.rawCount })?.rawCount
        else { return nil }

        let rightWidth = min(terminalRight, maxRightWidth)
        let middleBorderWidth = 1 + leftWidth + separator.count + rightWidth + 1

        var output = ""
        let middleBorder = String(repeating: horizontalBorder, count: middleBorderWidth)
        output.append("\(topLeftCorner)\(middleBorder)\(topRightCorner)\n")

        for (left, rights) in wrappedLines {
            output.append("\(leftBorder)\(left.padding(toSize: leftWidth))")
            output.append(separator)
            for (index, line) in rights.enumerated() {
                let right = "\(line.padding(toSize: rightWidth))\(rightBorder)\n"
                if index == 0 {
                    output.append(right)
                } else {
                    let leftPadding = "\(leftBorder)\(String(repeating: " ", count: leftWidth))\(separator)"
                    output.append("\(leftPadding)\(right)")
                }
            }
        }
        output.append("\(bottomLeftCorner)\(middleBorder)\(bottomRightCorner)")
        return output
    }
}
