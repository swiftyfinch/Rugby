//
//  DropMetrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

extension Drop {
    final class Metrics {
        private var removedTargets: Int?
        private var targets: Int?

        func collect(removedTargets: Int?, targets: Int?) {
            self.removedTargets = removedTargets
            self.targets = targets
        }

        func output() -> String {
            guard let removedTargets = removedTargets, let targets = targets else { return "" }
            return "Removed \(removedTargets)/\(targets) targets. ".green
        }
    }
}
