//
//  ProgressBarPrinter.swift
//  
//
//  Created by v.khorkov on 09.01.2021.
//

import Files
import Foundation

private extension TimeInterval {
    static let printInterval: TimeInterval = 0.2
}

protocol ProgressBarPrinter {
    func display(_ value: String, isEnd: Bool)
}

final class ProgressOneLinePrinter: ProgressBarPrinter {
    private var queue: [String] = []
    private var timer: Timer?
    private var lastPrint: TimeInterval?

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
        return dateFormatter
    }()

    private func setupTimer() -> Bool {
        guard timer == nil else { return false }
        print()
        let timer = Timer(timeInterval: .printInterval, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            guard !self.queue.isEmpty else { return }
            print(self.queue.removeFirst())
            self.lastPrint = ProcessInfo.processInfo.systemUptime
        })
        RunLoop.current.add(timer, forMode: .default)
        self.timer = timer
        return true
    }

    func display(_ value: String, isEnd: Bool) {
        queue.append("\u{1B}[1A\u{1B}[K\(value)")
        let elapsed = ProcessInfo.processInfo.systemUptime - (lastPrint ?? ProcessInfo.processInfo.systemUptime)
        if !isEnd, elapsed >= .printInterval {
            timer?.fire()
            return
        }
        if isEnd {
            timer?.invalidate()
            return queue.forEach { print($0) }
        }
        if setupTimer() { timer?.fire() }
    }
}

struct ProgressDefaultPrinter: ProgressBarPrinter {
    func display(_ value: String, isEnd: Bool) { print(value) }
}

final class LogProgressBarPrinter: ProgressBarPrinter {
    private let logFile: File
    init(file: File) { self.logFile = file }

    func display(_ value: String, isEnd: Bool) {
        try? logFile.append(value + "\n")
    }
}
