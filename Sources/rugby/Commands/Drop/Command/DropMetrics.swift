//
//  DropMetrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

extension Drop {
    final class Metrics: MetricsOutput {
        var targetsCount: MetricValue<Int> = .init()
        var compileFilesCount: MetricValue<Int> = .init()
        var projectSize: MetricValue<Int> = .init()

        func short() -> String {
            guard let removedTargets = targetsCount.after, let targets = targetsCount.before else { return "" }
            return "Removed \(removedTargets)/\(targets) targets.".green
        }

        func more() -> [String] {
            var outputs: [String] = []

            if let sizeBefore = projectSize.before, let sizeAfter = projectSize.after {
                let percent = (Double(sizeBefore - sizeAfter) / Double(sizeBefore)).outputPercent()
                outputs.append("Project size ".yellow + "↓\(percent)".green)
            }

            if let countBefore = compileFilesCount.before, let countAfter = compileFilesCount.after {
                let percent = (Double(countBefore - countAfter) / Double(countBefore)).outputPercent()
                outputs.append("Indexing files count ".yellow + "↓\(percent)".green)
            }

            return outputs
        }
    }
}
