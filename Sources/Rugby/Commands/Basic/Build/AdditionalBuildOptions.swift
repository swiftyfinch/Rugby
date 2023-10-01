import ArgumentParser

struct AdditionalBuildOptions: ParsableCommand {
    @Flag(name: .long, help: "Build without debug symbols.")
    var strip = false
}
