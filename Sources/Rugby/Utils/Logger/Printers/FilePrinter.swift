//
//  FilePrinter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 17.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Fish
import Foundation
import RugbyFoundation

// MARK: - Implementation

final class FilePrinter {
    private let file: IFile

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    init(file: IFile) {
        self.file = file
    }
}

// MARK: - Printer

extension FilePrinter: Printer {
    func canPrint(level: Int) -> Bool { true }

    func print(_ text: String, level: Int, updateLine: Bool) {
        let time = timeFormatter.string(from: Date())
        let text = "[\(time)]: \(text)\n".raw
        try? file.append(text)
    }
}
