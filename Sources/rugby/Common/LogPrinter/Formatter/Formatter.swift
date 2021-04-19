//
//  Formatter.swift
//  
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//

protocol Formatter {
    func format(text: String, time: String?) -> String
}

extension Formatter {
    func format(text: String, time: String? = nil) -> String {
        format(text: text, time: time)
    }
}
