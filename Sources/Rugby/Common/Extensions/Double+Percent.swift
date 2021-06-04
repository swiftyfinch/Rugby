//
//  Double+Percent.swift
//  
//
//  Created by Vyacheslav Khorkov on 23.04.2021.
//

extension Double {
    func outputPercent() -> String {
        String(Int(self * 100.0)) + "%"
    }
}
