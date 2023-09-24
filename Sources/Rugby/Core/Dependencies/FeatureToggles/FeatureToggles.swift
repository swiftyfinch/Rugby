//
//  FeatureToggles.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 18.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import RugbyFoundation

final class FeatureToggles: IFeatureToggles {
    var keepHashYamls: Bool {
        ProcessInfo.processInfo.environment["RUGBY_KEEP_HASH_YAMLS"] != nil
    }

    var printMissingBinaries: Bool {
        ProcessInfo.processInfo.environment["RUGBY_PRINT_MISSING_BINARIES"] != nil
    }
}
