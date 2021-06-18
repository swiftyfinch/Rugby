//
//  LogFormatter.swift
//  
//
//  Created by Vyacheslav Khorkov on 07.06.2021.
//

import XcbeautifyLib

final class LogFormatter {
    private var output: (String, OutputType) throws -> Void
    private var buffer: [String] = []
    private let minBufferSize = 3
    private let parser = Parser()

    init(output: @escaping (String, OutputType) throws -> Void) {
        self.output = output
    }

    func format(line: String) throws {
        buffer.append(line)
        if buffer.count >= minBufferSize {
            try parse()
        }
    }

    func finish() throws {
        while !buffer.isEmpty {
            try parse()
        }
    }

    private func parse() throws {
        guard let formatted = parser.parse(line: buffer.removeFirst(), additionalLines: { [weak self] in
            guard let self = self, !self.buffer.isEmpty else { return nil }
            return self.buffer.removeFirst()
        }) else { return }
        try output(formatted, parser.outputType)
    }
}
