//
//  String+Shell.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 14.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension String {
    var shellFriendly: String {
        replacingOccurrences(of: " ", with: "\\ ")
    }
}
