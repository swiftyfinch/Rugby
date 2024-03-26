import XcodeProj

// MARK: - Inteface

protocol IXcodeBuildConfigurationEditor: AnyObject {
    func copyBuildConfigurationList(from target: IInternalTarget, to destinationTarget: IInternalTarget)
}

// MARK: - Implemented

final class XcodeBuildConfigurationEditor {}

// MARK: - IXcodeBuildConfigurationEditor

extension XcodeBuildConfigurationEditor: IXcodeBuildConfigurationEditor {
    func copyBuildConfigurationList(from target: IInternalTarget, to destinationTarget: IInternalTarget) {
        let buildConfigurations = target.pbxTarget.buildConfigurationList?.buildConfigurations.map {
            XCBuildConfiguration(
                name: $0.name,
                baseConfiguration: $0.baseConfiguration,
                buildSettings: $0.buildSettings
            )
        } ?? []
        let buildConfigurationList = target.pbxTarget.buildConfigurationList.map {
            XCConfigurationList(
                buildConfigurations: buildConfigurations,
                defaultConfigurationName: $0.defaultConfigurationName,
                defaultConfigurationIsVisible: $0.defaultConfigurationIsVisible
            )
        }
        buildConfigurationList?.buildConfigurations.forEach(destinationTarget.project.pbxProj.add(object:))
        buildConfigurationList.map(destinationTarget.project.pbxProj.add(object:))
        destinationTarget.pbxTarget.buildConfigurationList = buildConfigurationList
    }
}
