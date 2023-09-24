//
//  FileContentEditor.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 27.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Fish
import Foundation

final class FileContentEditor {
    private let separator = "\""
    private let tokenPrefix = "${"

    func replace(_ replacements: [String: String], regex: NSRegularExpression, filePath: String) throws {
        guard File.isExist(at: filePath) else { return }

        let file = try File.at(filePath)
        let content = try file.read()
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        guard matches.isNotEmpty else { return }

        var newContent: String = ""
        var cursor = content.startIndex
        for match in matches {
            guard let range = Range(match.range, in: content) else { continue }

            let prefix = content[cursor..<range.lowerBound]
            newContent.append(contentsOf: prefix)
            cursor = range.upperBound

            let lookup = String(content[range])
            if let replacement = replacements[lookup] {
                newContent.append(contentsOf: replacement)
            }
        }

        let suffix = content[cursor..<content.endIndex]
        newContent.append(contentsOf: suffix)
        try file.write(newContent)
    }
}
