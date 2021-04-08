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
        let remotePods: Set<String>
        let checksums: [String]
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
}

extension CachePrepareStep {

    // todo: Remove "" from checksums
    // todo: Add substeps

    func run(_ buildTarget: String) throws -> Output {
        if try shellOut(to: "xcode-select -p") == .defaultXcodeCLTPath {
            throw CacheError.cantFineXcodeCommandLineTools
        }

        let podsProject = try XcodeProj(pathString: .podsProject)
        let (remotePods, filteredPods) = try findRemotePods(project: podsProject)
        let (buildPods, remoteChecksums) = try findBuildPods(pods: filteredPods)
        let targets = try buildTargetsChain(project: podsProject, pods: filteredPods)
        try addBuildTarget(project: podsProject, target: buildTarget, buildPods: buildPods, pods: filteredPods)
        let products = Set(targets.compactMap(\.product?.name))

        metrics.collect(podsCount: remotePods.count, checksums: remoteChecksums.count)
        done()
        return Output(scheme: buildPods.isEmpty ? nil : buildTarget,
                      remotePods: Set(targets.map(\.name)),
                      checksums: remoteChecksums,
                      products: products)
    }

    private func findRemotePods(project: XcodeProj) throws -> (all: Set<String>, filtered: Set<String>) {
        // Get remote pods from Podfile.lock
        let remotePods = Set(try Podfile(.podfileLock).getRemotePods())
        progress.output(remotePods, text: "Remote pods")

        // Exclude by command argument
        var remotePodsWithoutExcluded = remotePods
        if !command.exclude.isEmpty {
            progress.output(command.exclude, text: "Exclude pods")
            remotePodsWithoutExcluded.subtract(command.exclude)
        }

        // Exclude aggregated targets, which contain scripts with the installation of some xcframeworks.
        let (filteredPods, excluded) = project.excludeXCFrameworksTargets(pods: remotePodsWithoutExcluded)
        if !excluded.isEmpty {
            progress.output(excluded, text: "Exclude XCFrameworks")
        }

        return (remotePods, filteredPods)
    }

    func findBuildPods(pods: Set<String>) throws -> (buildPods: Set<String>, buildPodsChecksums: [String]) {
        let checksums = try Podfile(.podfileLock).getChecksums()
        let remoteChecksums = checksums.filter {
            guard let name = $0.components(separatedBy: ": ").first?
                    .trimmingCharacters(in: ["\""]) else { return false }
            return pods.contains(name)
        }

        // Find checksums difference from cache file
        if command.rebuild { return (pods, remoteChecksums) }

        let cacheFile = try CacheManager().load()
        if command.sdk != cacheFile.sdk || command.arch != cacheFile.arch { return (pods, remoteChecksums) }

        let cachedChecksums = cacheFile.checksums
        let changes = Set(remoteChecksums).subtracting(cachedChecksums)
        let changedPods = changes.compactMap {
            $0.components(separatedBy: ": ").first?.trimmingCharacters(in: ["\""])
        }
        return (Set(changedPods), remoteChecksums)
    }

    private func buildTargetsChain(project: XcodeProj, pods: Set<String>) throws -> Set<PBXTarget> {
        let remotePodsChain = project.buildRemotePodsChain(remotePods: Set(pods))
        guard remotePodsChain.count >= pods.count else { throw CacheError.cantFindRemotePodsTargets }

        let additionalBuildTargets = Set(remotePodsChain.map(\.name)).subtracting(pods)
        if !additionalBuildTargets.isEmpty {
            progress.output(additionalBuildTargets, text: "Additional build targets")
        }
        return remotePodsChain
    }

    private func addBuildTarget(project: XcodeProj, target: String, buildPods: Set<String>, pods: Set<String>) throws {
        // Include parents of build pods. Maybe it's not necessary?
        let buildPodsChain = project.findParentDependencies(Set(buildPods), allTargets: pods)
        if buildPodsChain.isEmpty {
            progress.update(info: "Skip".yellow)
        } else {
            progress.output(buildPodsChain, text: "Build pods")

            progress.update(info: "Add build target: ".yellow + target)
            project.pbxproj.addTarget(name: target, dependencies: buildPodsChain)

            progress.update(info: "Save project".yellow)
            try project.write(pathString: .podsProject, override: true)
        }
    }
}
