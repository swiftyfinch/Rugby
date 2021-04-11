//
//  CachePrepareStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import ShellOut
import XcodeProj

enum CacheSubstep {}

struct CachePrepareStep: Step {
    struct Output {
        let scheme: String?
        let remotePods: Set<String>
        let checksums: [String]
        let products: Set<String>
    }

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
        self.progress = RugbyProgressBar(title: "Prepare", logFile: logFile, verbose: verbose)
    }
}

extension CachePrepareStep {

    func run(_ buildTarget: String) throws -> Output {
        if try shellOut(to: "xcode-select -p") == .defaultXcodeCLTPath {
            throw CacheError.cantFineXcodeCommandLineTools
        }

        let podsProject = try XcodeProj(pathString: .podsProject)
        let factory = CacheSubstep.CacheSubstepFactory(progress: progress, command: command, metrics: metrics)
        let pods = try factory.findRemotePods(podsProject)
        let (buildPods, remoteChecksums) = try factory.findBuildPods(pods)
        let targets = try factory.buildTargetsChain(.init(project: podsProject, pods: pods))
        try factory.addBuildTarget(.init(target: buildTarget, project: podsProject, pods: pods, buildPods: buildPods))
        let products = Set(targets.compactMap(\.product?.name))

        done()
        return Output(scheme: buildPods.isEmpty ? nil : buildTarget,
                      remotePods: Set(targets.map(\.name)),
                      checksums: remoteChecksums,
                      products: products)
    }
}
