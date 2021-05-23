//
//  Regex.swift
//  
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//

import Foundation

enum RegexError: Error {
    case incorrectStringRange
}

func regex(_ pattern: String) throws -> NSRegularExpression {
    try NSRegularExpression(pattern: pattern)
}

extension String {
    func match(_ regex: NSRegularExpression) -> Bool {
        let matches = try? groups(regex)
        return matches?.isEmpty == false
    }

    func groups(_ regex: NSRegularExpression) throws -> [String] {
        guard let result = regex.firstMatch(self) else { return [] }
        return try (0..<result.numberOfRanges).map {
            let nsrange = result.range(at: $0)
            guard let range = Range(nsrange, in: self) else { throw RegexError.incorrectStringRange }
            return String(self[range])
        }
    }
}

private extension NSRegularExpression {
    func firstMatch(_ string: String) -> NSTextCheckingResult? {
        let range = NSRange(string.startIndex..., in: string)
        return firstMatch(in: string, range: range)
    }
}
