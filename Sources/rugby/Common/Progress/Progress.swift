//
//  Progress.swift
//  
//
//  Created by Vyacheslav Khorkov on 30.05.2021.
//

import Foundation

final class Spinner {
    private static let frames = [
        "",
        "•".red,
        "•".red + "•".yellow,
        "•".red + "•".yellow + "•".green,
        "•".red + "•".yellow + "•".green // It's delay
    ]
    private static let delay: UInt32 = 200_000
    private var sharedItem: DispatchWorkItem?

    func show<Result>(text: String? = nil, _ job: @escaping () throws -> Result) rethrows -> Result {
        // Run progress
        let item = makeProgressItem(text: text)
        sharedItem = item
        DispatchQueue.global().async(execute: item)

        // Do job
        let result = try job()

        // Stop progress
        item.cancel()
        item.wait()
        return result
    }

    private func makeProgressItem(text: String? = nil) -> DispatchWorkItem {
        DispatchWorkItem { [weak self] in
            print() // Go to newline
            while true {
                for frame in Self.frames {
                    var output = "\u{1B}[1A\u{1B}[K"
                    if self?.sharedItem?.isCancelled == true {
                        output.append("\u{1B}[1A")
                        return print(output)
                    } else {
                        text.map { output.append($0 + " ") }
                        output.append(frame)
                        print(output)
                    }
                    usleep(Self.delay)
                }
            }
        }
    }
}
