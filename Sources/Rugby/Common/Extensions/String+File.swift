//
//  String+File.swift
//  
//
//  Created by Vyacheslav Khorkov on 16.03.2021.
//

import Foundation

extension String {
    /// With extension
    func filename() -> String { components(separatedBy: "/").last ?? self }

    /// Without extension
    func basename() -> String {
        filename().components(separatedBy: ".").first ?? self
    }
}
