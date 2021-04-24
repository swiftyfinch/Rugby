//
//  Metrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 23.04.2021.
//

struct MetricValue<T> {
    var before: T?
    var after: T?
}

protocol Metrics: AnyObject {
    var project: String { get }

    var remotePodsCount: MetricValue<Int> { get set }
    var targetsCount: MetricValue<Int> { get set }
    var compileFilesCount: MetricValue<Int> { get set }
    var projectSize: MetricValue<Int> { get set }

    func short() -> String?
    func more() -> [String]
}

extension Array where Element == Metrics {
    func combine() -> Metrics? {
        guard count > 1 else { return first }
        guard let project = first?.project else { return nil }

        let metrics = CacheMetrics(project: project)

        metrics.remotePodsCount.before = first?.remotePodsCount.before
        metrics.remotePodsCount.after = last?.remotePodsCount.after

        metrics.targetsCount.before = first?.targetsCount.before
        metrics.targetsCount.after = last?.targetsCount.after

        metrics.compileFilesCount.before = first?.compileFilesCount.before
        metrics.compileFilesCount.after = last?.compileFilesCount.after

        metrics.projectSize.before = first?.projectSize.before
        metrics.projectSize.after = last?.projectSize.after

        return metrics
    }
}
