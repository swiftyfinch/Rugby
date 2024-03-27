public extension Vault {
    /// The service to parse YAML files with Rugby plans.
    var plansParser: IPlansParser { PlansParser(envVariablesResolver: envVariablesResolver) }
}
