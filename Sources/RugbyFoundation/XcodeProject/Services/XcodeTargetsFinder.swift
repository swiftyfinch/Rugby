import Foundation

final class XcodeTargetsFinder {
    private let targetsDataSource: XcodeTargetsDataSource

    init(targetsDataSource: XcodeTargetsDataSource) {
        self.targetsDataSource = targetsDataSource
    }

    func findTargets(by regex: NSRegularExpression? = nil,
                     except exceptRegex: NSRegularExpression? = nil,
                     includingDependencies: Bool = false) async throws -> Set<Target> {
        let targets = try await targetsDataSource.targets
        let foundTargets = try resolveTargets(targets: targets,
                                              by: regex,
                                              except: exceptRegex,
                                              includingDependencies: includingDependencies)
        return foundTargets
    }

    private func resolveTargets(targets: Set<Target>,
                                by regex: NSRegularExpression? = nil,
                                except exceptRegex: NSRegularExpression? = nil,
                                includingDependencies: Bool) throws -> Set<Target> {
        targets.filter {
            if let regex = exceptRegex, $0.name.match(regex) {
                return false
            } else if let regex {
                return $0.name.match(regex)
            }
            return true
        }.modifyIf(includingDependencies) { targets in
            let dependencies = targets.flatMap(\.dependencies)
            targets.formUnion(dependencies)
        }.filter {
            if let regex = exceptRegex, $0.name.match(regex) {
                return false
            }
            return true
        }
    }
}
