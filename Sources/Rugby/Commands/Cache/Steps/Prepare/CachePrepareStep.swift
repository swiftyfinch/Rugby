//
//  CachePrepareStep.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct CachePrepareStep: Step {
    struct Output {
        let scheme: String?
        let targets: Set<String>
        let buildInfo: BuildInfo
        let products: [String]
        let swiftVersion: String?
    }

    let verbose: Int
    let isLast: Bool
    let progress: Printer

    private let command: Cache
    private let metrics: Metrics

    init(command: Cache, metrics: Metrics, logFile: File, isLast: Bool = false) {
        self.command = command
        self.metrics = metrics
        self.verbose = command.flags.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Prepare", logFile: logFile, verbose: verbose, quiet: command.flags.quiet)
    }
}

extension CachePrepareStep {

    func run(_ buildTarget: String) throws -> Output {
        if try shell("xcode-select -p") == .defaultXcodeCLTPath {
            throw CacheError.cantFindXcodeCommandLineTools
        }

        metrics.projectSize.before = (try Folder.current.subfolder(at: .podsProject)).size()
        let project = try progress.spinner("Read project") {
            try ProjectProvider.shared.readProject(.podsProject)
        }
        metrics.compileFilesCount.before = project.pbxproj.buildFiles.count
        metrics.targetsCount.before = project.pbxproj.main.targets.count

        let projectPatched = project.pbxproj.main.contains(buildSettingsKey: .rugbyPatched)
        if projectPatched { throw CacheError.projectAlreadyPatched }

        let factory = CacheSubstepFactory(progress: progress, command: command, metrics: metrics)
        let selectedPods = try factory.selectPods(project)
        let (buildInfo, swiftVersion) = try factory.findBuildPods(selectedPods)
        let (selectedTargets, buildTargets) = try factory.buildTargets((project: project,
                                                                        selectedPods: selectedPods,
                                                                        buildPods: buildInfo.pods))
        if !buildTargets.isEmpty {
            try factory.addBuildTarget(.init(target: buildTarget, project: project, dependencies: buildTargets))
        }
        let targets = selectedPods
            .union(selectedTargets.map(\.name))
            .union(selectedTargets.compactMap(\.productName))

        done()
        return Output(scheme: buildTargets.isEmpty ? nil : buildTarget,
                      targets: targets,
                      buildInfo: buildInfo,
                      products: selectedTargets.compactMap(\.product?.name),
                      swiftVersion: swiftVersion)
    }
}
