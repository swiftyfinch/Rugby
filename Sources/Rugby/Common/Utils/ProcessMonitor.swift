//
//  ProcessMonitor.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 29.10.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import SwiftShell

/// Synchronise shell subprocesses
final class ProcessMonitor {
    static let shared = ProcessMonitor()

    private var isSync = false
    private let processes = NSHashTable<PrintedAsyncCommand>.weakObjects()
    private let signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)

    // MARK: - Internal Mehtods

    /// Keep links to all process
    func addProcess(_ process: PrintedAsyncCommand) {
        processes.add(process)
    }

    /// Catch SIGINT, clean up all subprocesses, and terminate root process manually
    static func sync() { shared.sync() }

    // MARK: - Private Methods

    private func sync() {
        if isSync { fatalError("Process sync already in progress") }
        isSync = true

        // Make sure the signal does not terminate the application.
        signal(SIGINT, SIG_IGN)
        signalSource.setEventHandler { [weak self] in
            self?.processes.allObjects.forEach { $0.interrupt() }
            exit(SIGINT)
        }
        signalSource.resume()
    }
}
