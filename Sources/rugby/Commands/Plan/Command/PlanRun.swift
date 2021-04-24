//
//  PlanRun.swift
//  
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//

import Files

extension Plans {
    func runPlans(_ plans: [PlanParser.Plan]) throws {
        let selectedPlan = try selectPlan(plans)
        let logFile = try Folder.current.createFile(at: .log)
        var allMetrics: [String: [Metrics]] = [:]
        let time = try measure {
            try selectedPlan.commands.forEach { command in
                var command = command
                var metrics: Metrics?
                let time = try measure {
                    metrics = try command.run(logFile: logFile)
                }
                if let metrics = metrics, !command.hideMetrics {
                    allMetrics[metrics.project, default: []].append(metrics)
                }
                outputCommand(metrics, logFile: logFile, time: time)
            }
        }
        outputFinalMetrics(allMetrics, logFile: logFile, time: time)
    }

    private func selectPlan(_ plans: [PlanParser.Plan]) throws -> PlanParser.Plan {
        if plan == nil, let defaultPlan = plans.first {
            return defaultPlan
        } else if let foundPlan = plans.first(where: { $0.name == plan }) {
            return foundPlan
        } else {
            throw PlanError.cantFindPlan
        }
    }
}

// MARK: - Output

extension Plans {
    private func outputCommand(_ metrics: Metrics?, logFile: File, time: Double) {
        if let metrics = metrics { outputShort(metrics, time: time, logFile: logFile) }
        printEmptyLine(logFile: logFile)
    }

    private func outputFinalMetrics(_ metrics: [String: [Metrics]],
                                    logFile: File,
                                    time: Double) {
        if let podsMetrics = metrics[String.podsProject.basename()] {
            outputProjectMetrics(podsMetrics, logFile: logFile)
        }

        let remainingMetricsProjects = metrics.keys
            .filter { $0 != String.podsProject.basename() }
            .sorted()
        for project in remainingMetricsProjects {
            guard let metrics = metrics[project] else { continue }
            outputProjectMetrics(metrics, logFile: logFile)
        }
        done(logFile: logFile, time: time)
    }

    private func outputProjectMetrics(_ metrics: [Metrics], logFile: File) {
        guard let combinedMetrics = metrics.combine() else { return }
        let projectHeader = "[!] " + combinedMetrics.project + ":"
        RugbyPrinter(logFile: logFile, verbose: true).print(projectHeader.green)
        outputMore(combinedMetrics, logFile: logFile)
        printEmptyLine(logFile: logFile)
    }

    private func printEmptyLine(logFile: File) {
        RugbyPrinter(logFile: logFile, verbose: true)
            .print("---------------------------------".yellow)
    }
}
