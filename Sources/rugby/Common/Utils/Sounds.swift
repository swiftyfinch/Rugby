//
//  Sounds.swift
//  
//
//  Created by Vyacheslav Khorkov on 03.05.2021.
//

import Foundation

func playBellSound() {
    _ = try? printShell("tput bel")
}
