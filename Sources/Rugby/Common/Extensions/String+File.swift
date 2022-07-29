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

    /// Drop file name and return folder path
    func dropFileName() -> String {
        components(separatedBy: "/")
            .dropLast()
            .joined(separator: "/")
    }

    /// Check if string contains dot
    var isDirectory: Bool {
        (try? URL(fileURLWithPath: self).resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }

    var shellFriendly: String { replacingOccurrences(of: " ", with: "\\ ") }
}
