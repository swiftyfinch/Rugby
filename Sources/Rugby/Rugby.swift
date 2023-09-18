import ArgumentParser
import Foundation

// It's a temporary main file only for support https://swiftpackageindex.com/swiftyfinch/Rugby
// I'm going to open source of Rugby this summer.
// You can find the Rugby1.x source code here: https://github.com/swiftyfinch/Rugby/tree/1.23.0

@main
struct Rugby: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        // Use someting from Foundation for excluding Linux from Swift Package Index.
        // Rugby doesn't support this platform.
        version: NSString(string: "2.0.3").description
    )
}
