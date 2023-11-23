import ArgumentParser

extension ParsableCommand {
    static func parseCommandType(
        arguments: [String] = CommandLine.arguments,
        lastNotDefaultTransition: Bool = false
    ) -> (type: ParsableCommand.Type, arguments: [String]) {
        var arguments = arguments
        var updated = true

        typealias Element = (type: ParsableCommand.Type, isDefaultTransition: Bool)
        var stack: [Element] = [(Self.self, false)]

        while updated {
            updated = false
            let argument = arguments.first
            let last = stack[stack.count - 1].type // It always has at least one element
            let subcommands = last.configuration.subcommands
            if let argument, let next = subcommands.first(where: { $0.configuration.commandName == argument }) {
                stack.append((next, false))
                arguments.removeFirst()
                updated = true
            } else if let defaultSubcommand = last.configuration.defaultSubcommand {
                stack.append((defaultSubcommand, true))
                updated = true
            }
        }

        // It always has at least Self command type
        let last: Element!
        if lastNotDefaultTransition {
            // It's needed for help printer
            last = stack.last(where: { $0.isDefaultTransition == false })
        } else {
            last = stack.last
        }

        return (last.type, arguments)
    }
}
