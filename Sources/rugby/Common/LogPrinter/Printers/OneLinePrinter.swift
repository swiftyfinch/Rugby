//
//  OneLinePrinter.swift
//  
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//

import Foundation

final class OneLinePrinter {
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
        Swift.print()
        let timer = Timer(timeInterval: .printInterval, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            guard !self.queue.isEmpty else { return }
            Swift.print(self.queue.removeFirst())
            self.lastPrint = ProcessInfo.processInfo.systemUptime
        })
        RunLoop.current.add(timer, forMode: .default)
        self.timer = timer
        return true
    }
}

extension OneLinePrinter: Printer {
    func print(_ value: String) {
        queue.append("\u{1B}[1A\u{1B}[K\(value)")
        let begin = lastPrint ?? ProcessInfo.processInfo.systemUptime
        let elapsed = ProcessInfo.processInfo.systemUptime - begin
        if elapsed >= .printInterval {
            timer?.fire()
            return
        }
        if setupTimer() { timer?.fire() }
    }

    func done() {
        if timer == nil { Swift.print() }
        timer?.invalidate()
        queue.forEach { Swift.print($0) }
    }
}

private extension TimeInterval {
    static let printInterval: TimeInterval = 0.2
}
