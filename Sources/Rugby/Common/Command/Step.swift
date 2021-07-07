//
//  Step.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
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
