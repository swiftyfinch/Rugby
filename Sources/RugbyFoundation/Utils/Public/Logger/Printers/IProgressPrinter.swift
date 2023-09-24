//
//  IProgressPrinter.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 18.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

/// The protocol describing a progress printer which can be used in the logger.
public protocol IProgressPrinter: Actor {
    /// Shows the progress.
    /// - Parameters:
    ///   - format: A format closure.
    ///   - job: A job to do.
    func show<Result>(format: @escaping (String) -> String,
                      job: () async throws -> Result) async rethrows -> Result

    /// Cancels showing of the progress.
    func cancel()
}
