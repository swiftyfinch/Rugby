//
//  Printer+Spinner.swift
//  
//
//  Created by Vyacheslav Khorkov on 30.05.2021.
//

extension Printer {
    @discardableResult
    func spinner<Result>(_ text: String, job: @escaping () throws -> Result) rethrows -> Result {
        defer { print("\(text) ⏱".yellow, level: .vv) }
        let result = try Spinner().show(text: text, job)
        return result
    }
}
