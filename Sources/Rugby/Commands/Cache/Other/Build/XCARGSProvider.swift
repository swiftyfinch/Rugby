//
//  XCARGSProvider.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 10.10.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct XCARGSProvider {
    private static let base = ["COMPILER_INDEX_STORE_ENABLE=NO",
                               "SWIFT_COMPILATION_MODE=wholemodule"]
    private static let useBitcode = "BITCODE_GENERATION_MODE=bitcode"

    static func xcargs(bitcode: Bool) -> [String] {
        var xcargs = base
        if bitcode { xcargs.append(useBitcode) }
        return xcargs
    }
}
