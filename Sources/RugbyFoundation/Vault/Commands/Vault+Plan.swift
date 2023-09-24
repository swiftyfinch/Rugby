//
//  Vault+Plan.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 05.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

extension Vault {
    /// The service to parse YAML files with Rugby plans.
    public var plansParser: IPlansParser { PlansParser() }
}
