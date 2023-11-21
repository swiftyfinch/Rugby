import ArgumentParser

struct AdditionalBuildOptions: ParsableCommand {
    @Flag(name: .long, help: "Build without debug symbols.")
    var strip = false

    @Option(name: .long, help: "Path for xcresult bundle.")
    var resultBundlePath: String?
}
