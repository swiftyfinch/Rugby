extension Scheme {
    func isReachable(fromReferences references: Set<String>) -> Bool {
        if references.contains(profileReference) { return true }
        if references.contains(launchReference) { return true }
        if !references.isDisjoint(with: testableReferences) { return true }
        if !references.isDisjoint(with: buildReferences) { return true }
        return false
    }

    private var launchReference: String? {
        xcscheme.launchAction?.runnable?.buildableReference?.blueprintIdentifier
    }

    private var profileReference: String? {
        xcscheme.profileAction?.buildableProductRunnable?.buildableReference?.blueprintIdentifier
    }

    private var testableReferences: [String] {
        xcscheme.testAction?.testables.compactMap(\.buildableReference.blueprintIdentifier) ?? []
    }

    private var buildReferences: [String] {
        xcscheme.buildAction?.buildActionEntries.compactMap(\.buildableReference.blueprintIdentifier) ?? []
    }
}
