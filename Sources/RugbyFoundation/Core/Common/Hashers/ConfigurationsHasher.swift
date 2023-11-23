import Foundation

final class ConfigurationsHasher {
    private let foundationHasher: FoundationHasher
    private let excludeKeys: Set<String>

    private let commonKey = "_Common"

    init(foundationHasher: FoundationHasher, excludeKeys: Set<String>) {
        self.foundationHasher = foundationHasher
        self.excludeKeys = excludeKeys
    }

    func hashContext(_ target: IInternalTarget) throws -> [Any] {
        guard let configurations = target.configurations?.values, configurations.isNotEmpty else { return [] }
        let sortedConfigurations = configurations.sorted { $0.name < $1.name }
        return separateCommonBuildSettings(sortedConfigurations)
    }

    // MARK: - Private

    private func separateCommonBuildSettings(_ configurations: [Configuration]) -> [[String: Any]] {
        guard let firstConfiguration = configurations.first else { return [] }

        guard configurations.count > 1 else {
            return [dictionary(name: firstConfiguration.name, buildSettings: firstConfiguration.buildSettings)]
        }

        var commonBuildSettings: [String: Any] = [:]
        let tailConfigurations = configurations.dropFirst()
        for (key, value) in firstConfiguration.buildSettings {
            let isCommonPair = tailConfigurations.allSatisfy { compareAny($0.buildSettings[key], value) }
            guard isCommonPair else { continue }
            commonBuildSettings[key] = value
        }

        let withoutCommonBuildSettings = configurations.map {
            dictionary(name: $0.name,
                       buildSettings: $0.buildSettings.filter { !compareAny(commonBuildSettings[$0.key], $0.value) })
        }

        return [dictionary(name: commonKey, buildSettings: commonBuildSettings)] + withoutCommonBuildSettings
    }

    private func dictionary(name: String, buildSettings: [String: Any]) -> [String: Any] {
        ["name": name, "buildSettings": removeRugbyKeys(buildSettings)]
    }

    private func compareAny(_ lhs: Any?, _ rhs: Any?) -> Bool {
        lhs.map { "\($0)" } == rhs.map { "\($0)" }
    }

    private func removeRugbyKeys(_ dictionary: [String: Any]) -> [String: Any] {
        var dictionary = dictionary
        for (key, _) in dictionary where excludeKeys.contains(key) {
            dictionary.removeValue(forKey: key)
        }
        return dictionary
    }
}
