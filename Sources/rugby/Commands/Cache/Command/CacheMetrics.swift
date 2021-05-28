//
//  CacheMetrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//

final class CacheMetrics {
    let project: String

    var remotePodsCount: MetricValue<Int> = .init()
    var targetsCount: MetricValue<Int> = .init()
    var compileFilesCount: MetricValue<Int> = .init()
    var projectSize: MetricValue<Int> = .init()

    init(project: String) {
        self.project = project
    }
}

extension CacheMetrics: Metrics {
    func short() -> String? {
        if let podsBefore = remotePodsCount.before, let podsAfter = remotePodsCount.after {
            return "Cached \(podsAfter)/\(podsBefore) remote pods.".green
        }
        return nil
    }

    func more() -> [String] {
        var lines: [String] = []

        if let sizeBefore = projectSize.before, let sizeAfter = projectSize.after {
            let percent = (Double(sizeBefore - sizeAfter) / Double(sizeBefore)).outputPercent()
            lines.append("Project size ".yellow + "↓\(percent)".green)
        }

        if let countBefore = compileFilesCount.before, let countAfter = compileFilesCount.after {
            let percent = (Double(countBefore - countAfter) / Double(countBefore)).outputPercent()
            lines.append("Indexing files count ".yellow + "↓\(percent)".green)
        }

        if let countBefore = targetsCount.before, let countAfter = targetsCount.after {
            let percent = (Double(countBefore - countAfter) / Double(countBefore)).outputPercent()
            lines.append("Targets count ".yellow + "↓\(percent)".green)
        }

        return lines
    }
}
