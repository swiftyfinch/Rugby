//
//  RugbyFormatter.swift
//  
//
//  Created by v.khorkov on 09.01.2021.
//

struct RugbyFormatter: Formatter {
    let title: String?

    func format(text: String, time: String?, chop: Int?) -> String {
        let choppendText = chop.map { text.width($0) } ?? text
        let ouputTitle = title.map { "\($0) ".green } ?? ""
        return (time ?? "") + ouputTitle + choppendText
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
