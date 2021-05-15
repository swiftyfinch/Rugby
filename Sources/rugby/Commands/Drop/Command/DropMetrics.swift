//
//  DropMetrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//

final class DropMetrics {
    let project: String

    var podsCount: MetricValue<Int> = .init()
    var targetsCount: MetricValue<Int> = .init()
    var compileFilesCount: MetricValue<Int> = .init()
    var projectSize: MetricValue<Int> = .init()

    init(project: String) {
        self.project = project
    }
}

extension DropMetrics: Metrics {
    func short() -> String? {
        if let removedTargets = targetsCount.after, let targets = targetsCount.before {
            return "Removed \(removedTargets)/\(targets) targets.".green
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

        return lines
    }
}
