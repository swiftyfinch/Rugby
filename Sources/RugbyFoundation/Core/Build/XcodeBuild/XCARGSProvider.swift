/// The provider of xcargs which is used in Rugby.
public final class XCARGSProvider {
    private let base = ["COMPILER_INDEX_STORE_ENABLE=NO",
                        "SWIFT_COMPILATION_MODE=wholemodule"]
    private let disableDebugSymbolsGeneration = "GCC_GENERATE_DEBUGGING_SYMBOLS=NO"
    private let stripDebugSymbols = [
        "STRIP_INSTALLED_PRODUCT=YES",
        "COPY_PHASE_STRIP=YES",
        "STRIP_STYLE=all"
    ]

    /// Returns xcargs which is used in Rugby.
    /// - Parameter strip: A flag to add xcargs for stripping debug symbols.
    public func xcargs(strip: Bool) -> [String] {
        var xcargs = base
        if strip {
            xcargs.append(disableDebugSymbolsGeneration)
            xcargs.append(contentsOf: stripDebugSymbols)
        }
        return xcargs
    }
}
