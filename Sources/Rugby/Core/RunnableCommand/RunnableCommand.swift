import ArgumentParser
import Darwin
import Fish
import Foundation
import Rainbow
import RugbyFoundation

// MARK: - Interface

protocol RunnableCommand: AsyncParsableCommand, Loggable {
    func body() async throws
}

// MARK: - Implementation

extension RunnableCommand {
    func run(_ block: () async throws -> Void,
             outputType: OutputType,
             logLevel: LogLevel,
             muteSound: Bool = false) async throws {
        defer {
            fflush(stdout) // We need to flush print buffer here before printing errors
            try? dependencies.metricsLogger.save()
            if !muteSound { playSoundIfNeeded(outputType: outputType) }
        }

        configureRainbow()
        try await prepareLogger(outputType: outputType, logLevel: logLevel)
        try await dependencies.environmentCollector.write(
            rugbyVersion: Rugby.configuration.version,
            command: self,
            workingDirectory: Folder.current,
            rugbyEnvironment: dependencies.featureToggles.all
        )

        let name = Self.configuration.commandName?.capitalized ?? "Unknown"
        let description = parseDescription()
        try await log("\(name.green)\(description)",
                      footer: name.green,
                      metricKey: name,
                      auto: await handle(block))
        await logPlain("\("⚑".yellow) Let's Roll-oll 🏈".green)
    }
}

// MARK: - Parse description

extension RunnableCommand {
    private func parseDescription() -> String {
        let arguments = Array(CommandLine.arguments.dropFirst())
        let (_, remainingArguments) = Rugby.parseCommandType(arguments: arguments)
        let description = remainingArguments.isEmpty ? "" : " \(remainingArguments.joined(separator: " "))"
        return description
    }
}

// MARK: - Play Sound

extension RunnableCommand {
    private func playSoundIfNeeded(outputType: OutputType) {
        guard !Debugger().isAttached(), !Terminal.isNoneTerminalOutput() else { return }
        switch outputType {
        case .fold, .multiline:
            dependencies.soundPlayer.playBell()
        case .raw, .silence:
            break
        }
    }
}

// MARK: - Configure Rainbow

extension RunnableCommand {
    private func configureRainbow() {
        guard ProcessInfo.processInfo.environment["NO_COLOR"] == nil else { return }
        if Debugger().isAttached() {
            Rainbow.outputTarget = .unknown
            Rainbow.enabled = false
        } else {
            Rainbow.outputTarget = .console
            Rainbow.enabled = true
        }
    }
}

// MARK: - Prepare logger

extension RunnableCommand {
    var logger: ILogger { dependencies.logger }

    private func prepareLogger(outputType: OutputType, logLevel: LogLevel) async throws {
        let logFolder = try dependencies.logsRotator.currentLogFolder()
        let logFile = try logFolder.createFile(named: "rugby.log")
        let filePrinter = FilePrinter(file: logFile)

        var outputType = outputType
        if (Terminal.isNoneTerminalOutput() && outputType == .fold) || Debugger().isAttached() {
            outputType = .multiline
        }

        let screenPrinter: Printer?
        let progressPrinter: ProgressPrinter?
        switch outputType {
        case .fold:
            let columns = Debugger().isAttached() ? Int.max : (Terminal.columns() ?? Int.max)
            let printer = OneLinePrinter(
                standardOutput: dependencies.standardOutput,
                maxLevel: logLevel,
                columns: columns
            )
            screenPrinter = printer
            progressPrinter = ProgressPrinter(
                printer: printer,
                timerTaskFactory: dependencies.timerTaskFactory,
                clock: Clock()
            )
            dependencies.processMonitor.runOnInterruption {
                Task { [weak progressPrinter] in await progressPrinter?.stop() }
            }
        case .multiline:
            screenPrinter = MultiLinePrinter(
                standardOutput: dependencies.standardOutput,
                maxLevel: logLevel
            )
            progressPrinter = nil
        case .raw:
            screenPrinter = RawPrinter(
                standardOutput: dependencies.standardOutput,
                maxLevel: logLevel
            )
            progressPrinter = nil
        case .silence:
            screenPrinter = nil
            progressPrinter = nil
        }
        await dependencies.logger.configure(screenPrinter: screenPrinter,
                                            filePrinter: filePrinter,
                                            progressPrinter: progressPrinter,
                                            metricsLogger: dependencies.metricsLogger)
    }
}
