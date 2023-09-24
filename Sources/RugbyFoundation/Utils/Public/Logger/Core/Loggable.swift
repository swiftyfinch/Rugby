//
//  Loggable.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 18.02.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

/// The protocol describing the convenient way to use a logger.
public protocol Loggable {
    /// The specific logger instance.
    var logger: ILogger { get }
}

extension Loggable {
    /// Logs block.
    /// - Parameters:
    ///   - header: A header of block.
    ///   - footer: A footer of block.
    ///   - metricKey: An optional metric key.
    ///   - level: A level of logging.
    ///   - output: An output type.
    ///   - block: An autoclosure to do.
    @discardableResult
    public func log<Result>(
        _ header: String,
        footer: String? = nil,
        metricKey: String? = nil,
        level: LogLevel = .compact,
        output: LoggerOutput = .all,
        auto block: @autoclosure () async throws -> Result
    ) async rethrows -> Result {
        try await logger.log(
            header.green,
            footer: footer,
            metricKey: metricKey,
            level: level,
            output: output,
            block: block
        )
    }

    /// Logs block.
    /// - Parameters:
    ///   - header: A header of block.
    ///   - footer: A footer of block.
    ///   - metricKey: An optional metric key.
    ///   - level: A level of logging.
    ///   - output: An output type.
    ///   - block: A closure to do.
    @discardableResult
    public func log<Result>(
        _ header: String,
        footer: String? = nil,
        metricKey: String? = nil,
        level: LogLevel = .compact,
        output: LoggerOutput = .all,
        block: () async throws -> Result
    ) async rethrows -> Result {
        try await logger.log(
            header.green,
            footer: footer,
            metricKey: metricKey,
            level: level,
            output: output,
            block: block
        )
    }

    /// Logs text.
    /// - Parameters:
    ///   - text: A text to log.
    ///   - level: A level of logging.
    ///   - output: An output type.
    public func log(
        _ text: String,
        level: LogLevel = .compact,
        output: LoggerOutput = .all
    ) async {
        await logger.log(
            text.green,
            level: level,
            output: output
        )
    }

    /// Logs plain text.
    /// - Parameters:
    ///   - text: A text to log.
    ///   - level: A level of logging.
    ///   - output: An output type.
    public func logPlain(
        _ text: String,
        level: LogLevel = .compact,
        output: LoggerOutput = .all
    ) async {
        await logger.logPlain(
            text,
            level: level,
            output: output
        )
    }
}
