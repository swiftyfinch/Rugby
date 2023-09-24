//
//  Dependencies.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 19.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import RugbyFoundation

extension AsyncParsableCommand {
    var dependencies: Vault { Vault.shared }
    static var dependencies: Vault { Vault.shared }
    static var settings: Settings { Vault.shared.settings }
}
