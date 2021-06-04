//
//  Formatter.swift
//  
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//

protocol Formatter {
    func format(text: String, time: String?, chop: Int?) -> String
}

extension Formatter {
    func format(text: String, time: String? = nil, chop: Int? = nil) -> String {
        format(text: text, time: time, chop: chop)
    }
}
