//
//  Printer+Spinner.swift
//  
//
//  Created by Vyacheslav Khorkov on 30.05.2021.
//

extension Printer {
    func spinner<R>(_ text: String, job: @escaping () throws -> R) rethrows -> R {
        let result = try Progress().show(text: text, job)
        print("\(text) ⏱".yellow, level: .vv)
        return result
    }
}
