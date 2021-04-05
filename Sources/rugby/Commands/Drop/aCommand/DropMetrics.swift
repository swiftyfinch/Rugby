//
//  DropMetrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

extension Drop {
    final class Metrics {
        var removedTargets: Int?
        var targets: Int?

        func output() -> String {
            guard let removedTargets = removedTargets, let targets = targets else { return "" }
            return "Removed \(removedTargets)/\(targets) targets. ".green
        }
    }
}
