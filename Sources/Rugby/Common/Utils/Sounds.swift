//
//  Sounds.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 03.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

func playBellSound() {
    _ = try? printShell("tput bel")
}
