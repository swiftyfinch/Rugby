//
//  String+File.swift
//  
//
//  Created by Vyacheslav Khorkov on 16.03.2021.
//

import Foundation

extension String {
    func filename() -> String? { components(separatedBy: "/").last }
}
