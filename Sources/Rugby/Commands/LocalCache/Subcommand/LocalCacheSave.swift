//
//  LocalCacheSave.swift
//
//
//  Created by mlch911 on 2023/3/16.
//

import ArgumentParser
import Files
import Foundation
import PathKit
import XcodeProj

extension LocalCache {
    struct LocalCacheSave: ParsableCommand, Command {
        @OptionGroup var options: Options
        @OptionGroup var flags: CommonFlags

        static var configuration = CommandConfiguration(
            abstract: "• Sync local cached Pods to Local Cache."
        )

        var quiet: Bool {
            flags.quiet
        }

        var nonInteractive: Bool {
            flags.nonInteractive
        }

        mutating func run(logFile: Files.File) throws -> Metrics? {
            let progress = RugbyPrinter(title: "LocalCacheSave", verbose: flags.verbose, quiet: flags.quiet, nonInteractive: flags.nonInteractive)
            try LocalCacheSaveStep(options: options, progress: progress).run()
            try LocalCacheCleanStep(options: options, progress: progress, cleanAll: false).run()
            return nil
        }
    }
}

struct LocalCacheSaveStep: Step {
    let progress: Printer
    let options: LocalCache.Options

    init(options: LocalCache.Options, progress: Printer) {
        self.progress = progress
        self.options = options
    }

    func run(_ input: Void) throws {
        guard !options.location.isEmpty else { throw LocalCacheError.locationNotFound }
        try run("Check Project") { try LocalCache.Util.checkProjectPatched() }

        let projectName = try options.projectName ?? run("Find Project Name") { try LocalCache.Util.findProjectName(options.mainProjectLocation) }
        guard !projectName.isEmpty else { throw LocalCacheError.projectNameNotFound }

        guard let caches = try run("Read cache file", job: CacheManager().load) else { throw LocalCacheError.cacheNotFound }
        guard !caches.values.isEmpty else { throw LocalCacheError.checksumsNotFound }

        let path = Path(options.location)
        if !path.absolute().exists {
            try path.absolute().mkdir()
        }
        let remoteLocation = try Folder(path: options.location).createSubfolderIfNeeded(withName: projectName)
        try caches.forEach { name, cache in
            let remoteFolder = try remoteLocation.createSubfolderIfNeeded(withName: cache.localCacheFolderName())
            let sourceFolder = try Folder(path: .buildFolder).subfolder(named: name)
            let frameworkFolder = try? sourceFolder.subfolder(named: .buildFrameworkFolder)
            let savedPod = try PodsProvider.shared.pods().filter { pod in
                let copyFramework = try copyFrameworkIfNeed(pod: pod, remoteFolder: remoteFolder, frameworkFolder: frameworkFolder)
                let copyPod = try copyPodIfNeed(pod: pod, remoteFolder: remoteFolder, sourceFolder: sourceFolder)
                return copyFramework || copyPod
            }
        }
        done()
    }

    private func copyPodIfNeed(pod: Pod, remoteFolder: Folder, sourceFolder: Folder) throws -> Bool {
        let podFolder = try remoteFolder.createSubfolderIfNeeded(withName: pod.name)
        let podSourceFolder = try sourceFolder.subfolder(named: pod.name)
        let podLastCachedFolder: Folder

        if podFolder.containsSubfolder(named: try podChecksum(pod)) {
            podLastCachedFolder = try podFolder.subfolder(named: podChecksum(pod))
            if (try podLastCachedFolder.contentChecksum()) == (try podSourceFolder.contentChecksum()) {
                return false
            } else {
                progress.print("[\(pod.name)]Previous cache pod is not valid. Rewrite it.", level: 0)
                try podLastCachedFolder.deleteAllContent()
            }
        } else {
            podLastCachedFolder = try podFolder.createSubfolderIfNeeded(withName: podChecksum(pod))
        }

        progress.print("Copy Cache:[\(pod.name)]", level: 0)
        try podSourceFolder.copyAllContent(to: podLastCachedFolder)
        return true
    }

    private func copyFrameworkIfNeed(pod: Pod, remoteFolder: Folder, frameworkFolder: Folder?) throws -> Bool {
        guard let frameworkFolder = frameworkFolder, frameworkFolder.containsSubfolder(named: pod.name) else { return false }
        let folder = try frameworkFolder.subfolder(named: pod.name)

        let targetFolder = try remoteFolder
            .createSubfolderIfNeeded(withName: .buildFrameworkFolder)
            .createSubfolderIfNeeded(withName: pod.name)
            .createSubfolderIfNeeded(withName: podChecksum(pod))

        if (try folder.contentChecksum()) == (try targetFolder.contentChecksum()) {
            return false
        } else {
            progress.print("[\(pod.name) Framework]Previous cache pod is not valid. Rewrite it.", level: 0)
            try targetFolder.deleteAllContent()
        }

        progress.print("Copy Framework Cache:[\(pod.name)]", level: 0)
        try folder.copyAllContent(to: targetFolder)
        return true
    }

    private func podChecksum(_ pod: Pod) throws -> String {
        try pod.contentChecksum(useContentChecksums: options.useContentChecksums).value
    }

    private func run<Result>(_ text: String, job: @escaping () throws -> Result) throws -> Result {
        if verbose.bool {
            return try progress.spinner(text, job: job)
        } else {
            return try job()
        }
    }
}

enum LocalCacheError: Error {
    case locationNotFound
    case notPatched
    case cacheNotFound
    case loadPodsFail
    case checksumsNotFound

    case mainProjectNotFound
    case foundMoreThanOneProject
    case projectNameNotFound
}
