//
//  CacheMetrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

extension Cache {
    final class Metrics: MetricsOutput {
        var remotePodsCount: MetricValue<Int> = .init()
        var compileFilesCount: MetricValue<Int> = .init()
        var projectSize: MetricValue<Int> = .init()
        var targetsCount: MetricValue<Int> = .init()

        func short() -> String {
            guard let podsBefore = remotePodsCount.before, let podsAfter = remotePodsCount.after else { return "" }
            return "Cached \(podsAfter)/\(podsBefore) remote pods.".green
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

            if let countBefore = targetsCount.before, let countAfter = targetsCount.after {
                let percent = (Double(countBefore - countAfter) / Double(countBefore)).outputPercent()
                outputs.append("Targets count ".yellow + "↓\(percent)".green)
            }

            return outputs
        }
    }
}
