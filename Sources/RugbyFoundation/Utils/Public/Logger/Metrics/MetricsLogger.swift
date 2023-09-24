//
//  MetricsLogger.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 11.02.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Fish

/// The protocol describing a service to log commands metrics.
public protocol IMetricsLogger: AnyObject {
    /// Logs a new metrics.
    /// - Parameters:
    ///   - metric: A double value of metric.
    ///   - name: A name of metric.
    func log(_ metric: Double, name: String)

    /// Rewrites the current metric value adding a new one.
    /// - Parameters:
    ///   - metric: A double value of metric.
    ///   - name: A name of metric.
    func add(_ metric: Double, name: String)

    /// Saves all metrics to file.
    func save() throws
}

// MARK: - Implementation

/// The service to log commands metrics.
public final class MetricsLogger {
    private let folderPath: String

    private var metrics: [String: Double] = [:]
    private let fileName = "+metrics"

    /// Initialized.
    /// - Parameter folderPath: The path to the metrics folder.
    public init(folderPath: String) {
        self.folderPath = folderPath
    }

    private func makeKey(name: String) -> String {
        let plainKey = name.raw.lowercased()
        let withoutNumbersInBrackets = plainKey
            .components(separatedBy: "(").first?
            .trimmingCharacters(in: [" "])

        return (withoutNumbersInBrackets ?? plainKey)
            .replacingOccurrences(of: " ", with: "_")
    }

    private func prepareMetric(_ metric: Double) -> String {
        String(Double(Int(metric * 100.0)) / 100.0)
    }
}

// MARK: - IMetricsLogger

extension MetricsLogger: IMetricsLogger {
    public func log(_ metric: Double, name: String) {
        metrics[makeKey(name: name)] = metric
    }

    public func add(_ metric: Double, name: String) {
        metrics[makeKey(name: name), default: 0] += metric
    }

    public func save() throws {
        let folder = try Folder.create(at: folderPath)
        let content = metrics
            .sorted { $0.key < $1.key }
            .map { "\($0): \(prepareMetric($1))" }
            .joined(separator: "\n")
        try folder.createFile(named: fileName, contents: content)
    }
}

extension IMetricsLogger {
    func log(_ metric: Int, name: String) {
        log(Double(metric), name: name)
    }
}
