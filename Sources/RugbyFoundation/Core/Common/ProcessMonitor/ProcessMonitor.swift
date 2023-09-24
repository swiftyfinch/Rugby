//
//  ProcessMonitor.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 04.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import SwiftShell

// MARK: - Interface

/// The protocol describing a service to monitor Rugby child processes.
public protocol IProcessMonitor {
    /// Starts to monitor Rugby process.
    func monitor()

    /// Adds subprocess for monitoring.
    /// - Parameter process: A process of shell command.
    func addProcess(_ process: PrintedAsyncCommand)

    /// Adds a job to run after Rugby process interruption.
    /// - Parameter job: A job to run.
    @discardableResult
    func runOnInterruption(_ job: @escaping () -> Void) -> ProcessInterruptionTask
}

// MARK: - Implementation

/// Synchronise shell subprocesses
final class ProcessMonitor {
    private let processes = NSHashTable<PrintedAsyncCommand>.weakObjects()
    private let signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
    private var interruptionTasks: [ProcessInterruptionTask] = []
    private var isSync = false
}

// MARK: - IProcessMonitor

extension ProcessMonitor: IProcessMonitor {
    /// Catch SIGINT, clean up all subprocesses, and terminate root process manually
    public func monitor() {
        if isSync { return /* Process monitor is already in progress */ }
        isSync = true

        // Make sure the signal does not terminate the application.
        signal(SIGINT, SIG_IGN)
        signalSource.setEventHandler { [weak self] in
            guard let self = self else { return }
            print(" ✕ Interruption, please wait a bit.".red)
            self.processes.allObjects.forEach { $0.interrupt() }
            self.interruptionTasks.forEach { $0.run() }
            exit(SIGINT)
        }
        signalSource.resume()
    }

    /// Keep links to all process
    public func addProcess(_ process: PrintedAsyncCommand) {
        processes.add(process)
    }

    @discardableResult
    public func runOnInterruption(_ job: @escaping () -> Void) -> ProcessInterruptionTask {
        let interruptionTask = ProcessInterruptionTask(job: job)
        interruptionTasks.append(interruptionTask)
        return interruptionTask
    }
}
