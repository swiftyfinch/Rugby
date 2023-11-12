/// The protocol describing a service providing the feature toggles.
public protocol IFeatureToggles: AnyObject {
    /// The feature names and their values.
    var all: [String: String] { get }

    /// A flag to keep yaml files with target hash in the binaries folder.
    var keepHashYamls: Bool { get }

    /// A flag to print missing binaries as a tree during an analysing process.
    var printMissingBinaries: Bool { get }
}
