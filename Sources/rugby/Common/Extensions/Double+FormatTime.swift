//
//  Double+FormatTime.swift
//  
//
//  Created by v.khorkov on 04.01.2021.
//

import Foundation

extension Double {
    func formatTime() -> String {
        let formatter = DateComponentsFormatter()

        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en")
        formatter.calendar = calendar

        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 2
        return formatter.string(from: max(1, self)) ?? "NaN"
    }

    func output() -> String {
        "[\(formatTime())] ".yellow
    }
}
