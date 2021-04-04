//
//  RugbyProgressBar.swift
//  
//
//  Created by v.khorkov on 09.01.2021.
//

import Files
import Foundation

final class RugbyProgressBar {
    private let formatter: RugbyFormatter
    private var progressBar: ProgressBar
    private let begin = ProcessInfo.processInfo.systemUptime
    private let verbose: Bool

    init(count: Int = Int.max,
         title: String,
         logFile: File? = nil,
         verbose: Bool = false) {
        self.formatter = RugbyFormatter(title: title)

        var printers: [ProgressBarPrinter] = []
        logFile.map { printers.append(LogProgressBarPrinter(file: $0)) }
        printers.append(verbose ? ProgressDefaultPrinter() : ProgressOneLinePrinter())
        self.progressBar = ProgressBar(
            count: count,
            formatter: self.formatter,
            printers: printers
        )
        self.verbose = verbose
    }

    func showCount(_ count: Int) {
        formatter.showCount = true
        progressBar.count = count
        progressBar.setValue(0)
    }

    func update(info: String) {
        formatter.info = info
        progressBar.next()
    }

    func done() {
        let time = ProcessInfo.processInfo.systemUptime - begin
        formatter.info = "✓"
        formatter.time = "[\(time.formatTime())] ".yellow
        progressBar.setValue(progressBar.count)
    }
}
