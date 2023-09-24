//
//  String+Quotes.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 07.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension String {
    var quoted: String {
        #""\#(self)""#
    }
}
