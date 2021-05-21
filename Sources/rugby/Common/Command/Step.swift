//
//  Step.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

protocol Step {
    var verbose: Int { get }
    var isLast: Bool { get }
    var progress: Printer { get }

    associatedtype Input
    associatedtype Output
    associatedtype Run = (Input) throws -> Output
    func run(_ input: Input) throws -> Output

    func done()
}

// MARK: - Default implementation

extension Step {
    var verbose: Int { 0 }
    var isLast: Bool { false }

    func done() {
        progress.done()
    }
}

extension Step where Input == Void {
    func run() throws -> Output {
        try run(Void())
    }
}
