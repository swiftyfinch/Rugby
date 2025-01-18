import ArgumentParser
import RugbyFoundation

extension SDK: @retroactive ExpressibleByArgument {}
extension Architecture: @retroactive ExpressibleByArgument {}

struct BuildOptions: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "Build SDK: sim or ios.")
    var sdk: SDK = .sim

    @Option(name: .shortAndLong, help: "Build architecture: auto, x86_64 or arm64.")
    var arch: Architecture = .auto

    @Option(name: .shortAndLong, help: "Build configuration.")
    var config = "Debug"

    @OptionGroup
    var additionalBuildOptions: AdditionalBuildOptions

    @OptionGroup
    var targetsOptions: TargetsOptions

    func xcodeBuildOptions(
        skipSigning: Bool = false,
        resultBundlePath: String? = nil
    ) -> XcodeBuildOptions {
        XcodeBuildOptions(
            sdk: sdk,
            config: config,
            arch: resolveArchitecture().rawValue,
            xcargs: dependencies.xcargsProvider.xcargs(
                strip: additionalBuildOptions.strip,
                skipSigning: skipSigning
            ),
            resultBundlePath: resultBundlePath
        )
    }

    private func resolveArchitecture() -> Architecture {
        (arch == .auto) ? autoArchitecture() : arch
    }

    private func autoArchitecture() -> Architecture {
        switch sdk {
        case .ios: return .arm64
        case .sim: return dependencies.architectureProvider.architecture()
        }
    }
}
