import Fish
import Foundation

final class FileContentEditor {
    func replace(_ replacements: [String: String], regex: NSRegularExpression, filePath: String) throws {
        guard File.isExist(at: filePath) else { return }
        let file = try File.at(filePath)
        try replace(replacements, regex: regex, file: file)
    }

    func replace(_ replacements: [String: String], regex: NSRegularExpression, file: IFile) throws {
        let content = try file.read()
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        guard matches.isNotEmpty else { return }

        var newContent: String = ""
        var cursor = content.startIndex
        for match in matches {
            guard let range = Range(match.range, in: content) else { continue }

            let prefix = content[cursor ..< range.lowerBound]
            newContent.append(contentsOf: prefix)
            cursor = range.upperBound

            let lookup = String(content[range])
            if let replacement = replacements[lookup] {
                newContent.append(contentsOf: replacement)
            }
        }

        let suffix = content[cursor ..< content.endIndex]
        newContent.append(contentsOf: suffix)
        try file.write(newContent)
    }
}
