//
//  String+Extension.swift
//  RugbyFoundation
//
//  Created by Khorkov Vyacheslav on 06.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension String {
    func excludingExtension() -> String {
        guard let lastIndex = lastIndex(of: ".") else { return self }
        return String(self[startIndex..<lastIndex])
    }
}
