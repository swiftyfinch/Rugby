import Foundation

/// A set of options to to select targets.
public struct TargetsOptions {
    /// A mode where only the selected targets are printed.
    var tryMode: Bool
    /// A RegEx to select targets.
    var targetsRegex: NSRegularExpression?
    /// A RegEx to exclude targets.
    var exceptTargetsRegex: NSRegularExpression?

    /// - Parameters:
    ///   - tryMode: A mode where only the selected targets are printed.
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    public init(
        tryMode: Bool = false,
        targetsRegex: NSRegularExpression? = nil,
        exceptTargetsRegex: NSRegularExpression? = nil
    ) {
        self.tryMode = tryMode
        self.targetsRegex = targetsRegex
        self.exceptTargetsRegex = exceptTargetsRegex
    }
}

// MARK: - TargetsScope

enum TargetsScope {
    case exact(TargetsMap)
    case filter(regex: NSRegularExpression?, exceptRegex: NSRegularExpression?)
}

extension TargetsScope {
    init(_ targetsOptions: TargetsOptions) {
        self = .filter(
            regex: targetsOptions.targetsRegex,
            exceptRegex: targetsOptions.exceptTargetsRegex
        )
    }
}
