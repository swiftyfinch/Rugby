//
//  String+SHA1.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 15.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

extension String {
    func sha1() -> String {
        return Data(utf8).sha1()
    }
}
