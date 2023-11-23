import Foundation

final class XcodeTargetsFinder {
    private let targetsDataSource: XcodeTargetsDataSource

    init(targetsDataSource: XcodeTargetsDataSource) {
        self.targetsDataSource = targetsDataSource
    }

    func findTargets(by regex: NSRegularExpression? = nil,
                     except exceptRegex: NSRegularExpression? = nil,
                     includingDependencies: Bool = false) async throws -> TargetsMap {
        let targets = try await targetsDataSource.targets
        return try resolveTargets(targets: targets,
                                  by: regex,
                                  except: exceptRegex,
                                  includingDependencies: includingDependencies)
    }

    private func resolveTargets(targets: TargetsMap,
                                by regex: NSRegularExpression? = nil,
                                except exceptRegex: NSRegularExpression? = nil,
                                includingDependencies: Bool) throws -> TargetsMap {
        targets.filter { _, target in
            if let regex = exceptRegex, target.name.match(regex) {
                return false
            } else if let regex {
                return target.name.match(regex)
            }
            return true
        }.modifyIf(includingDependencies) { targets in
            let dependencies = targets.flatMapValues(\.dependencies)
            targets.merge(dependencies)
        }.filter { _, target in
            if let regex = exceptRegex, target.name.match(regex) {
                return false
            }
            return true
        }
    }
}
