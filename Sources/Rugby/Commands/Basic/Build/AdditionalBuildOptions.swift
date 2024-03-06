import ArgumentParser

struct AdditionalBuildOptions: ParsableCommand {
    @Flag(name: .long, help: "Build without debug symbols.")
    var strip = false

    @Flag(name: .long, help: "Disable code signing.")
    var skipSigning = false
}
