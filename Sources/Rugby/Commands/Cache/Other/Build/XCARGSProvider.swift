//
//  XCARGSProvider.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 10.10.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct XCARGSProvider {
    private let base = ["COMPILER_INDEX_STORE_ENABLE=NO",
                        "SWIFT_COMPILATION_MODE=wholemodule"]
    private let disableDebugSymbolsGeneration = "GCC_GENERATE_DEBUGGING_SYMBOLS=NO"
    private let stripDebugSymbols = [
        "STRIP_INSTALLED_PRODUCT=YES",
        "COPY_PHASE_STRIP=YES",
        "STRIP_STYLE=all"
    ]
    private let useBitcode = "BITCODE_GENERATION_MODE=bitcode"

    func xcargs(bitcode: Bool, withoutDebugSymbols: Bool) -> [String] {
        var xcargs = base
        if bitcode { xcargs.append(useBitcode) }
        if withoutDebugSymbols {
            xcargs.append(disableDebugSymbolsGeneration)
            xcargs.append(contentsOf: stripDebugSymbols)
        }
        return xcargs
    }
}
