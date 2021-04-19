//
//  RugbyFormatter.swift
//  
//
//  Created by v.khorkov on 09.01.2021.
//

struct RugbyFormatter: Formatter {
    let title: String

    func format(text: String, time: String?) -> String {
        (time ?? "") + "\(title) ".green + text
    }
}
