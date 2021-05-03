//
//  Sounds.swift
//  
//
//  Created by Vyacheslav Khorkov on 03.05.2021.
//

import Foundation
import ShellOut

func playBellSound() {
    _ = try? shellOut(to: "tput bel", outputHandle: .standardOutput)
}
