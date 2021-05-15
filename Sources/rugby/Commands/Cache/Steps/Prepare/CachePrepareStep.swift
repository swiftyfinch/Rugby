//
//  CachePrepareStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import XcodeProj

struct CachePrepareStep: Step {
    struct Output {
        let scheme: String?
        let pods: Set<String>
        let checksums: [Checksum]
        let products: Set<String>
        let swiftVersion: String?
    }

    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let command: Cache
    private let metrics: Metrics

    init(command: Cache, metrics: Metrics, logFile: File, isLast: Bool = false) {
        self.command = command
        self.metrics = metrics
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Prepare", logFile: logFile, verbose: verbose)
    }
}

extension CachePrepareStep {

    func run(_ buildTarget: String) throws -> Output {
        if try shell("xcode-select -p") == .defaultXcodeCLTPath {
            throw CacheError.cantFindXcodeCommandLineTools
        }

        progress.print("Read project ⏱".yellow)
        metrics.projectSize.before = (try Folder.current.subfolder(at: .podsProject)).size()
        let project = try XcodeProj(pathString: .podsProject)
        metrics.compileFilesCount.before = project.pbxproj.buildFiles.count
        metrics.targetsCount.before = project.pbxproj.main.targets.count
        let factory = CacheSubstepFactory(progress: progress, command: command, metrics: metrics)
        let selectedPods = try factory.selectPods(project)
        let (buildPods, focusChecksums, swiftVersion) = try factory.findBuildPods(selectedPods)
        let (selectedTargets, buildTargets) = try factory.buildTargets((project: project,
                                                                        selectedPods: selectedPods,
                                                                        buildPods: buildPods))
        if !buildTargets.isEmpty {
            try factory.addBuildTarget(.init(target: buildTarget, project: project, dependencies: buildTargets))
        }

        done()
        return Output(scheme: buildTargets.isEmpty ? nil : buildTarget,
                      pods: Set(selectedTargets.map(\.name)).union(selectedPods),
                      checksums: focusChecksums,
                      products: Set(selectedTargets.compactMap(\.product?.name)),
                      swiftVersion: swiftVersion)
    }
}
