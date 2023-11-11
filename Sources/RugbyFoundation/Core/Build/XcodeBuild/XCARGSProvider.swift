/// The provider of xcargs which is used in Rugby.
public final class XCARGSProvider {
    private let base = ["COMPILER_INDEX_STORE_ENABLE=NO",
                        "SWIFT_COMPILATION_MODE=wholemodule"]
    private let codeSigningNotAllowed = "CODE_SIGNING_ALLOWED=NO"
    private let disableDebugSymbolsGeneration = "GCC_GENERATE_DEBUGGING_SYMBOLS=NO"
    private let stripDebugSymbols = [
        "STRIP_INSTALLED_PRODUCT=YES",
        "COPY_PHASE_STRIP=YES",
        "STRIP_STYLE=all"
    ]

    /// Returns xcargs which is used in Rugby.
    /// - Parameter strip: A flag to add xcargs for stripping debug symbols.
    /// - Parameter skipSigning: A flag to skip code signing of products.
    public func xcargs(
        strip: Bool,
        skipSigning: Bool = false
    ) -> [String] {
        var xcargs = base
        if strip {
            xcargs.append(disableDebugSymbolsGeneration)
            xcargs.append(contentsOf: stripDebugSymbols)
        }
        if skipSigning {
            xcargs.append(codeSigningNotAllowed)
        }
        return xcargs
    }
}
