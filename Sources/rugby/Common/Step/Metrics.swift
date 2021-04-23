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

protocol MetricsOutput {
    func short() -> String
    func more() -> [String]
}
