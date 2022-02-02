//
//  PlanRun.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

extension Plans {
    func runPlans(_ plans: [PlanParser.Plan]) throws {
        defer { try? HistoryWriter().save() }

        let selectedPlan = try selectPlan(plans)
        let logFile = try Folder.current.createFile(at: .log)
        EnvironmentCollector().write(to: logFile)

        var metrics: [String: [Metrics]] = [:]
        let time = try measure {
            try runPlan(selectedPlan, plans: plans, logFile: logFile, metrics: &metrics)
        }
        outputFinalMetrics(metrics, logFile: logFile, time: time)
    }

    private func selectPlan(_ plans: [PlanParser.Plan]) throws -> PlanParser.Plan {
        if plan == nil, let defaultPlan = plans.first {
            return defaultPlan
        } else if let foundPlan = plans.first(where: { $0.name == plan }) {
            return foundPlan
        } else {
            throw PlanError.cantFindPlan(plan ?? .firstPlan)
        }
    }

    private func runPlan(_ plan: PlanParser.Plan,
                         plans: [PlanParser.Plan],
                         logFile: File,
                         metrics allMetrics: inout [String: [Metrics]]) throws {
        printSelectedPlan(plan: plan.name, logFile: logFile)
        try plan.commands.forEach { command in
            // Let's try to switch to sub-plan
            if let reference = command as? PlansReference {
                return try runSubPlan(reference, plans: plans, logFile: logFile, metrics: &allMetrics)
            }

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

    private func runSubPlan(_ reference: PlansReference,
                            plans: [PlanParser.Plan],
                            logFile: File,
                            metrics allMetrics: inout [String: [Metrics]]) throws {
        guard let plan = plans.first(where: { $0.name == reference.name }) else {
            throw PlanError.cantFindPlan(reference.name)
        }
        try runPlan(plan, plans: plans, logFile: logFile, metrics: &allMetrics)
    }
}

// MARK: - Output

extension Plans {
    private func outputCommand(_ metrics: Metrics?, logFile: File, time: Double) {
        if let metrics = metrics { outputShort(metrics, time: time, logFile: logFile, quiet: cacheOptions.flags.quiet) }
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
        done(logFile: logFile, time: time, quiet: cacheOptions.flags.quiet)
    }

    private func outputProjectMetrics(_ metrics: [Metrics], logFile: File) {
        guard let combinedMetrics = metrics.combine() else { return }
        let projectHeader = "[!] " + combinedMetrics.project + ":"
        RugbyPrinter(logFile: logFile, verbose: .verbose, quiet: cacheOptions.flags.quiet).print(projectHeader.green)
        outputMore(combinedMetrics, logFile: logFile, quiet: cacheOptions.flags.quiet)
        printEmptyLine(logFile: logFile)
    }

    private func printEmptyLine(logFile: File) {
        RugbyPrinter(logFile: logFile, verbose: .verbose, quiet: cacheOptions.flags.quiet).print(.separator)
    }

    private func printSelectedPlan(plan: String, logFile: File) {
        RugbyPrinter(title: "Plans ✈️ ", logFile: logFile, verbose: .verbose, quiet: cacheOptions.flags.quiet)
            .print("\(plan.yellow)")
    }
}

private extension String {
    static let firstPlan = "first"
}
