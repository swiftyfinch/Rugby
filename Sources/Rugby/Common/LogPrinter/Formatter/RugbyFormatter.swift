//
//  RugbyFormatter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct RugbyFormatter: Formatter {
    let title: String?

    func format(text: String, time: String?, chop: Int?) -> String {
        let choppendText = chop.map { text.width($0) } ?? text
        return [time, title?.green, choppendText]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}

private extension String {
    func width(_ width: Int) -> String {
        guard count > width else { return self }
        let tail = width > 3 ? "..." : ""
        let offset = width - tail.count
        return String(self[..<index(startIndex, offsetBy: offset)]) + tail
    }
}
