import ArgumentParserToolInfo
import RugbyFoundation

private extension String {
    static let hiddenCommandsPrefix = "-"
}

final class HelpPrinter {
    private let terminalWidth = Terminal.columns() ?? 80
    private let arguments: [(String, ArgumentInfoV0.KindV0)] = [
        ("Arguments", .positional),
        ("Options", .option),
        ("Flags", .flag)
    ]

    func print(command: CommandInfoV0) {
        var blocks: [String] = []

        let abstractBlock = block(abstract: command.abstract?.removingPrefix(.hiddenCommandsPrefix))
        blocks.append(abstractBlock)

        if let block = block(subcommands: command.subcommands ?? [],
                             defaultSubcommand: command.defaultSubcommand) {
            blocks.append(block)
        }

        let argumentsBlocks = arguments.compactMap { title, kind in
            block(title: title, arguments: command.arguments ?? [], kind: kind)
        }
        blocks.append(contentsOf: argumentsBlocks)

        if let discussion = command.discussion {
            blocks.append(buildDiscussion(discussion))
        }

        Swift.print(blocks.joined(separator: "\n"))
    }

    private func block(abstract: String?) -> String {
        var output = ""
        let abstract = abstract ?? "-"
        if abstract.raw.contains(">") {
            output.append(abstract)
        } else {
            let prefix = " \(">".black.bold.onAccent) "
            /* TODO: Support multiline abstract?
              let lines = discussion.components(separatedBy: .newlines).flatMap {
                  $0.wordWrappedLines(width: terminalWidth - prefix.rawCount - 1)
              }
             */
            let words = abstract.wordWrappedLines(width: terminalWidth - prefix.rawCount - 1)
            let shiftedAbstract = words.enumerated().map { index, line in
                if index == 0 {
                    return "\(prefix)\(line)"
                } else {
                    return "\(String(repeating: " ", count: prefix.rawCount))\(line)"
                }
            }.joined(separator: "\n")
            output.append("\n")
            output.append(shiftedAbstract)
        }
        output.append("\n")
        return output
    }

    private func formatTitle(_ title: String) -> String {
        " \(title):".bold.accent
    }

    private func block(subcommands: [CommandInfoV0], defaultSubcommand: String?) -> String? {
        var lines: [(left: String, right: String)] = []
        for subcommand in subcommands {
            guard let abstract = subcommand.abstract else { continue }
            guard !abstract.hasPrefix(.hiddenCommandsPrefix) else { continue }
            let left = subcommand.commandName == defaultSubcommand
                ? subcommand.commandName.bold.accent
                : subcommand.commandName
            lines.append((
                left: left,
                right: abstract
            ))
        }
        return buildTableBlock(title: "Subcommands", lines: lines)
    }

    private func block(title: String,
                       arguments: [ArgumentInfoV0],
                       kind: ArgumentInfoV0.KindV0) -> String? {
        var lines: [(left: String, right: String)] = []
        for argument in arguments.filter({ $0.kind == kind }) {
            lines.append((
                left: argument.displayName,
                right: argument.help
            ))
        }
        return buildTableBlock(title: title, lines: lines)
    }

    private func buildTableBlock(title: String, lines: [(left: String, right: String)]) -> String? {
        guard let table = BoxPainter().drawTable(lines, separator: "  ", terminalWidth: terminalWidth)
        else { return nil }

        return "\(formatTitle(title))\n\(table)"
    }

    private func buildDiscussion(_ discussion: String) -> String {
        var blocks: [String] = []
        blocks.append("")
        blocks.append(" \("i".black.bold.onAccent) \("Find more in Docs".bold.yellow) (⌘ + double click on the url)")
        discussion.components(separatedBy: "\n").forEach {
            blocks.append("   \($0)")
        }
        blocks.append("")
        return blocks.joined(separator: "\n")
    }
}

private extension ArgumentInfoV0 {
    var help: String {
        var result = abstract ?? "-"
        if let defaultValue {
            if result.contains(defaultValue) {
                result = result.replacingOccurrences(of: defaultValue, with: defaultValue.accent)
            } else {
                result.append(" \("(\(defaultValue))".accent)")
            }
        }
        return result
    }
}

private extension [ArgumentInfoV0.NameInfoV0] {
    var string: String {
        sorted(by: { $0.kind.string.count < $1.kind.string.count })
            .map(\.string)
            .joined(separator: ", ")
    }
}

private extension ArgumentInfoV0.NameInfoV0.KindV0 {
    var string: String {
        switch self {
        case .long: return "--"
        case .short: return "-"
        case .longWithSingleDash: return "-"
        }
    }
}

private extension ArgumentInfoV0.NameInfoV0 {
    var string: String { "\(kind.string)\(name)" }
}

private extension ArgumentInfoV0 {
    var displayName: String {
        var result: String
        let repeatingSuffix = isRepeating ? " []" : ""
        switch kind {
        case .positional:
            result = "\(valueName ?? "-")\(repeatingSuffix)"
        case .option, .flag:
            result = "\(names?.string ?? "-")\(repeatingSuffix)"
        }
        result = isOptional ? result : result.bold
        return result
    }
}

private extension String {
    func removingPrefix(_ prefix: String) -> Self {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}
