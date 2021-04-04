//
//  CachePrepareStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import ShellOut
import XcodeProj

final class CachePrepareStep: Step {
    struct Output {
        let scheme: String?
        let buildPods: [String]
        let remotePods: Set<String>
        let checksums: [String]
        let podsCount: Int
        let products: Set<String>
    }

    let name = "Prepare"
    let verbose: Bool
    let isLast: Bool
    let progress: RugbyProgressBar

    private let command: Cache
    private let metrics: Cache.Metrics

    init(command: Cache, metrics: Cache.Metrics, logFile: File, isLast: Bool = false) {
        self.command = command
        self.metrics = metrics
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyProgressBar(title: name, logFile: logFile, verbose: verbose)
    }

    func run(_ buildTarget: String) throws -> Output {
        if try shellOut(to: "xcode-select -p") == .defaultXcodeCLTPath {
            throw CacheError.cantFineXcodeCommandLineTools
        }

        // Get remote pods from Podfile.lock
        let podfile = try Podfile(.podfileLock)
        let remotePods = try podfile.getRemotePods().map { $0.trimmingCharacters(in: ["\""]) }
        progress.update(info: "Remote pods ".yellow + "(\(remotePods.count))" + ":".yellow)
        remotePods.caseInsensitiveSorted().forEach { progress.update(info: "* ".yellow + "\($0)") }

        var filteredRemotePods = exclude(pods: Set(command.exclude), from: remotePods)

        // Exclude aggregated targets, which contain scripts with the installation of some xcframeworks.
        let podsProject = try XcodeProj(pathString: .podsProject)
        filteredRemotePods = excludeXCFrameworksTargets(project: podsProject, pods: filteredRemotePods)

        let checksums = try podfile.getChecksums()
        let remoteChecksums = checksums.filter {
            guard let name = $0.components(separatedBy: ": ").first?
                    .trimmingCharacters(in: ["\""]) else { return false }
            return filteredRemotePods.contains(name)
        }

        let buildPods = try findBuildPods(remotePods: filteredRemotePods, checksums: remoteChecksums, command: command)

        // Collect all remote pods chain
        let remotePodsChain = buildRemotePodsChain(project: podsProject, remotePods: Set(filteredRemotePods))
        guard remotePodsChain.count >= filteredRemotePods.count else { throw CacheError.cantFindRemotePodsTargets }

        let additionalBuildTargets = Set(remotePodsChain.map(\.name)).subtracting(filteredRemotePods)
        if !additionalBuildTargets.isEmpty {
            progress.update(info: "Additional build targets ".yellow + "(\(additionalBuildTargets.count))" + ":".yellow)
            additionalBuildTargets.caseInsensitiveSorted().forEach { progress.update(info: "* ".yellow + "\($0)") }
        }

        // Include parents of build pods
        let buildPodsChain = podsProject.findParentDependencies(Set(buildPods), allTargets: filteredRemotePods)

        if buildPodsChain.isEmpty {
            progress.update(info: "Skip".yellow)
        } else {
            progress.update(info: "Build pods ".yellow + "(\(buildPodsChain.count))" + ":".yellow)
            buildPodsChain.caseInsensitiveSorted().forEach { progress.update(info: "* ".yellow + "\($0)") }

            progress.update(info: "Add build target: ".yellow + buildTarget)
            podsProject.pbxproj.addTarget(name: buildTarget, dependencies: buildPodsChain)

            progress.update(info: "Save project".yellow)
            try podsProject.write(pathString: .podsProject, override: true)
        }

        // Prepare list of products like: Some.framework, Some.bundle
        let products = Set(remotePodsChain.compactMap(\.product?.name))

        done()
        return Output(scheme: buildPods.isEmpty ? nil : buildTarget,
                      buildPods: buildPodsChain,
                      remotePods: Set(remotePodsChain.map(\.name)),
                      checksums: remoteChecksums,
                      podsCount: remoteChecksums.count,
                      products: products)
    }

    private func exclude(pods: Set<String>, from remotePods: [String]) -> [String] {
        var remotePods = remotePods
        if !pods.isEmpty {
            progress.update(info: "Exclude pods ".yellow + "(\(pods.count))" + ":".yellow)
            pods.caseInsensitiveSorted().forEach { progress.update(info: "* ".yellow + "\($0)") }
            remotePods.removeAll(where: { pods.contains($0) })
        }
        return remotePods
    }

    private func excludeXCFrameworksTargets(project: XcodeProj, pods: [String]) -> [String] {
        let aggregateTargets = project.pbxproj.aggregateTargets.reduce(into: Set<String>()) { set, target in
            let phaseNames = target.buildPhases.compactMap { $0.name() }
            if phaseNames.contains(where: { $0.contains("XCFrameworks") }) {
                set.insert(target.name)
            }
        }
        let excluded = pods.filter { aggregateTargets.contains($0) }
        if !excluded.isEmpty {
            progress.update(info: "Exclude XCFrameworks ".yellow + "(\(excluded.count))" + ":".yellow)
            excluded.caseInsensitiveSorted().forEach { progress.update(info: "* ".yellow + "\($0)") }
        }
        return Array(Set(pods).subtracting(excluded))
    }

    private func findBuildPods(remotePods: [String], checksums: [String], command: Cache) throws -> [String] {
        if command.rebuild { return remotePods }

        let cacheFile = try CacheManager().load()
        if command.sdk != cacheFile.sdk || command.arch != cacheFile.arch { return remotePods }

        let cachedChecksums = cacheFile.checksums
        let changes = Set(checksums).subtracting(cachedChecksums)
        let changedPods = changes.compactMap { $0.components(separatedBy: ": ").first?.trimmingCharacters(in: ["\""]) }
        return changedPods.caseInsensitiveSorted()
    }

    private func buildRemotePodsChain(project: XcodeProj, remotePods: Set<String>) -> Set<PBXTarget> {
        remotePods.reduce(into: Set<PBXTarget>()) { chain, name in
            let targets = Set(project.pbxproj.targets(named: name))
            chain.formUnion(targets)

            let dependencies = targets.reduce(Set<PBXTarget>()) { set, target in
                let dependencies = target.dependencies.filter {
                    // Check that it's a part of remote pod
                    guard let prefix = $0.name?.components(separatedBy: "-").first else { return true }
                    return remotePods.contains(prefix)
                }
                return set.union(dependencies.compactMap(\.target))
            }
            chain.formUnion(dependencies)
        }
    }
}
