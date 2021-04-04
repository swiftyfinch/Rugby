//
//  Step.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

class Step {
    private let verbose: Bool
    private let isLast: Bool
    let progress: RugbyProgressBar

    init(name: String, logFile: File? = nil, verbose: Bool, isLast: Bool = false) {
        self.verbose = verbose
        self.isLast = isLast
        self.progress = RugbyProgressBar(title: name,
                                         logFile: logFile,
                                         verbose: verbose)
    }

    func done() {
        progress.done()
        if verbose && !isLast { print("------------------------------------------------".yellow) }
    }
}

// ---------------------------------------------------------------------------------------------------------------------

protocol NewStep {
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

private extension String {
    static let logSeparator = String(repeating: "-", count: 48)
}

extension NewStep {
    var verbose: Bool { false }
    var isLast: Bool { false }

    func done() {
        progress.done()
        if verbose && !isLast { print(String.logSeparator.yellow) }
    }
}

extension NewStep where Input == Void {
    func run() throws -> Output {
        try run(Void())
    }
}
