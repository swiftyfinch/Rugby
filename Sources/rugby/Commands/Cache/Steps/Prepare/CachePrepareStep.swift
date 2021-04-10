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

    typealias Substeps = CacheSubstep

    func run(_ buildTarget: String) throws -> Output {
        if try shellOut(to: "xcode-select -p") == .defaultXcodeCLTPath {
            throw CacheError.cantFineXcodeCommandLineTools
        }

        let podsProject = try XcodeProj(pathString: .podsProject)
        let findRemotePods = Substeps.FindRemotePods(progress: progress, command: command, metrics: metrics)
        let findBuildPods = Substeps.FindBuildPods(progress: progress, command: command, metrics: metrics)
        let buildTargetsChain = Substeps.BuildTargetsChain(progress: progress)
        let addBuildTarget = Substeps.AddBuildTarget(progress: progress)
        let flow =
            findRemotePods.run
            | findBuildPods.run
            | buildTargetsChain.run
            | addBuildTarget.run
        let result = try flow(.init(target: buildTarget, project: podsProject))
        let products = Set(result.targets.compactMap(\.product?.name))

        done()
        return Output(scheme: result.buildPods.isEmpty ? nil : buildTarget,
                      remotePods: Set(result.targets.map(\.name)),
                      checksums: result.remoteChecksums,
                      products: products)
    }
}
