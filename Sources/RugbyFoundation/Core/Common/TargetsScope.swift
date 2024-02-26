import Foundation

enum TargetsScope {
    case exact(TargetsMap)
    case filter(regex: NSRegularExpression?, exceptRegex: NSRegularExpression?)
}
