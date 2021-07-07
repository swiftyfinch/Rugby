//
//  String+File.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 16.03.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
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
