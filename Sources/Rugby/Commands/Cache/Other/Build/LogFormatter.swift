//
//  LogFormatter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 07.06.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcbeautifyLib

final class LogFormatter {
    private var output: (String, OutputType) throws -> Void
    private var buffer: [String] = []
    private let minBufferSize = 3
    private(set) lazy var parser: Parser = {
        .init { [weak self] in
            guard let self = self, !self.buffer.isEmpty else { return nil }
            return self.buffer.removeFirst()
        }
    }()

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
        guard let formatted = parser.parse(line: buffer.removeFirst()) else { return }
        try output(formatted, parser.outputType)
    }
}
