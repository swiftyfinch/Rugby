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

    var podsCount: MetricValue<Int> { get set }
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

        metrics.podsCount.before = first?.podsCount.before
        metrics.targetsCount.before = first?.targetsCount.before
        metrics.compileFilesCount.before = first?.compileFilesCount.before
        metrics.projectSize.before = first?.projectSize.before

        metrics.podsCount.after = lastNotNil(where: \.podsCount.after)
        metrics.targetsCount.after = lastNotNil(where: \.targetsCount.after)
        metrics.compileFilesCount.after = lastNotNil(where: \.compileFilesCount.after)
        metrics.projectSize.after = lastNotNil(where: \.projectSize.after)

        return metrics
    }

    /// Iterate from tail each element and stop when mapped element returns not nil.
    private func lastNotNil<T>(where mapBlock: (Element) -> T?) -> T? {
        for element in reversed() {
            guard let notNil = mapBlock(element) else { continue }
            return notNil
        }
        return nil
    }
}
