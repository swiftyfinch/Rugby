import XcodeProj

extension PBXTarget {
    func constructConfigurations(
        _ projectBuildConfigurations: [String: XCBuildConfiguration]
    ) throws -> [String: Configuration]? {
        try buildConfigurationList?.buildConfigurations.reduce(into: [:]) { dictionary, config in
            guard let xcconfigPath = config.baseConfiguration?.fullPath,
                  let projectBuildSettings = projectBuildConfigurations[config.name]?.buildSettings else { return }

            let xcconfig = try XCConfig(path: .init(xcconfigPath))
            let buildSettings = projectBuildSettings
                .merging(xcconfig.buildSettings, uniquingKeysWith: combineKeys)
                .merging(config.buildSettings, uniquingKeysWith: combineKeys)

            dictionary?[config.name] = Configuration(name: config.name, buildSettings: buildSettings)
        }
    }

    private func combineKeys(_ lhs: BuildSetting, rhs: BuildSetting) -> BuildSetting {
        guard let lhs = lhs.stringValue, let rhs = rhs.stringValue else { return rhs }
        return BuildSetting.string(
            rhs.replacingOccurrences(of: "$(inherited)", with: lhs)
        )
    }
}
