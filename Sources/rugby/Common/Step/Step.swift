//
//  Step.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

protocol Step {
    var name: String { get }

    var verbose: Bool { get }
    var isLast: Bool { get }
    var progress: RugbyProgressBar { get }

    associatedtype Input
    associatedtype Output
    func run(_ input: Input) throws -> Output

    func done()
}

// MARK: - Default implementation

extension Step {
    var verbose: Bool { false }
    var isLast: Bool { false }

    func done() {
        progress.done()
        if verbose && !isLast { /* do nothing */ }
    }
}

extension Step where Input == Void {
    func run() throws -> Output {
        try run(Void())
    }
}
