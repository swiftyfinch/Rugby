//
//  RugbyFormatter.swift
//  
//
//  Created by v.khorkov on 09.01.2021.
//

final class RugbyFormatter: ProgressBarFormatter {
    private let title: String
    var info: String
    var time: String?
    var showCount = false

    init(title: String, info: String = "⏱", time: String? = nil) {
        self.title = title
        self.info = info
        self.time = time
    }

    func format(index: Int, count: Int) -> String {
        let count = showCount ? " \(index)/\(count)" : ""
        let timeBlock = time ?? ""
        return timeBlock + "\(title)\(count) ".green + info
    }
}
