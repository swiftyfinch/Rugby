//
//  Double+TimeFormat.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 18.02.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

extension Double {
    private static let formatter = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en")

        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 2
        return formatter
    }()

    func format(withMilliseconds: Bool = true) -> String {
        let seconds = Double(Int(self))
        let milliseconds = Int(truncatingRemainder(dividingBy: 1) * 10)
        let correctedSum = seconds + Double(milliseconds / 10)
        guard let string = Self.formatter.string(from: correctedSum) else { return "NaN" }

        guard withMilliseconds else { return string }

        // Add mileseconds: 1s -> 1.9s
        var timeComponents = string.components(separatedBy: " ")
        if let last = timeComponents.last, last.hasSuffix("s") {
            timeComponents[timeComponents.count - 1] = "\(String(last.dropLast())).\(milliseconds)s"
        }
        return timeComponents.joined(separator: " ")
    }
}
