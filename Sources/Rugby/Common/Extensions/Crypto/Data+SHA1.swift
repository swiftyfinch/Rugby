//
//  Data+SHA1.swift
//  Rugby
//
//  Created by Colton Schlosser on 03.08.2022.
//

import CryptoKit
import Foundation

extension Data {
    func sha1() -> String {
        Insecure.SHA1.hash(data: self).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
