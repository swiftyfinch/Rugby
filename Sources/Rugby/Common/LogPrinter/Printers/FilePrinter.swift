//
//  FilePrinter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

struct FilePrinter: Printer {
    private let logFile: File
    init(file: File) { self.logFile = file }

    func print(_ value: String, level: Int) {
        try? logFile.append(value + "\n")
    }
    func done() {}

    @discardableResult
    func spinner<Result>(_ text: String, job: @escaping () throws -> Result) rethrows -> Result {
        fatalError("Not implemented")
    }
}
