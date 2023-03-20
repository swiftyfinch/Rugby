//
//  LocalCacheFetch.swift
//  
//
//  Created by mlch911 on 2023/3/16.
//

import ArgumentParser
import Files
import Foundation
import XcodeProj
import PathKit

extension LocalCache {
    struct LocalCacheFetch: ParsableCommand, Command {
        @OptionGroup var options: Options
        @OptionGroup var flags: CommonFlags
        @OptionGroup var buildOptions: Cache
        
        static var configuration = CommandConfiguration(
            abstract: "• Sync Local Cached Pods to Local."
        )
        
        var quiet: Bool {
            flags.quiet
        }
        
        var nonInteractive: Bool {
            flags.nonInteractive
        }
        
        mutating func run(logFile: Files.File) throws -> Metrics? {
            let progress = RugbyPrinter(title: "LocalCacheFetch", verbose: flags.verbose, quiet: flags.quiet, nonInteractive: flags.nonInteractive)
            try LocalCacheFetchStep(options: options, progress: progress, buildOptions: buildOptions).run()
            return nil
        }
    }
}

struct LocalCacheFetchStep: Step {
    let progress: Printer
    let options: LocalCache.Options
    let buildOptions: Cache
    
    private let checksumsProvider: ChecksumsProvider
    private let cacheManager = CacheManager()
    
    init(options: LocalCache.Options, progress: Printer, buildOptions: Cache) {
        self.progress = progress
        self.options = options
        self.buildOptions = buildOptions
        self.checksumsProvider = ChecksumsProvider(useContentChecksums: options.useContentChecksums)
    }
    
    func run(_ input: Void) throws {
        guard !options.location.isEmpty else { throw LocalCacheError.locationNotFound }
        
        let projectName = try options.projectName ?? run("Find Project Name") { try LocalCache.Util.findProjectName(options.mainProjectLocation) }
        guard !projectName.isEmpty else { throw LocalCacheError.projectNameNotFound }
        
        let path = Path(options.location)
        guard path.absolute().exists else { return }
        
        let remoteLocation = try Folder(path: options.location).createSubfolderIfNeeded(withName: projectName)
        for (sdk, arch) in zip(buildOptions.sdk, buildOptions.arch) {
            let fakeCache = BuildCache(sdk: sdk,
                                       arch: arch,
                                       config: buildOptions.config,
                                       swift: SwiftVersionProvider().swiftVersion(),
                                       xcargs: XCARGSProvider().xcargs(bitcode: buildOptions.bitcode, withoutDebugSymbols: buildOptions.offDebugSymbols),
                                       checksums: nil)
            let folderName = fakeCache.LocalCacheFolderName()
            guard remoteLocation.containsSubfolder(named: folderName) else { return }
            let buildFolder = try Folder(path: .supportFolder).createSubfolder(named: "build").createSubfolderIfNeeded(withName: fakeCache.cacheKeyName())
            let copyPods = try copyPodsFromRemote(remoteLocation.subfolder(named: folderName), buildFolder)
            
            guard !copyPods.isEmpty else { return }
            // Update Cache File
            let pods = Set<String>(copyPods.map(\.name))
            let newChecksums = try checksumsProvider.getChecksums(forPods: pods)
            let cachedChecksums = cacheManager.checksumsMap(sdk: sdk, config: buildOptions.config)
            let updatedChecksums = newChecksums.reduce(into: cachedChecksums) { checksums, new in
                checksums[new.name] = new
            }
            let checksums = updatedChecksums.map(\.value.string).sorted()
            let newCache = BuildCache(sdk: fakeCache.sdk,
                                      arch: fakeCache.arch,
                                      config: fakeCache.config,
                                      swift: fakeCache.swift,
                                      xcargs: fakeCache.xcargs,
                                      checksums: checksums)
            try cacheManager.update(cache: newCache)
        }
        done()
    }
    
    private func copyPodsFromRemote(_ remoteFolder: Folder, _ localFolder: Folder) throws -> [Pod] {
        try PodsProvider.shared.pods().compactMap { pod in
            let copyPod = try copyPodFromRemote(pod, remoteFolder, localFolder)
            let copyFramework = try copyPodFrameworkFromRemote(pod, remoteFolder, localFolder)
            if copyPod || copyFramework {
                return pod
            }
            return nil
        }
    }
    
    private func copyPodFromRemote(_ pod: Pod, _ remoteFolder: Folder, _ localFolder: Folder) throws -> Bool {
        guard let podRemoteFolder = try? remoteFolder
            .subfolder(named: pod.name)
            .subfolder(named: podChecksum(pod))
        else { return false }
        let podLocalFolder = try localFolder.createSubfolderIfNeeded(withName: pod.name)
        guard (try podRemoteFolder.contentChecksum()) != (try podLocalFolder.contentChecksum()) else { return false }
        try podLocalFolder.deleteAllContent()
        try podRemoteFolder.copyAllContent(to: podLocalFolder)
        return true
    }
    
    private func copyPodFrameworkFromRemote(_ pod: Pod, _ remoteFolder: Folder, _ localFolder: Folder) throws -> Bool {
        guard let remotePodFrameworkFolder = try? remoteFolder
            .subfolder(named: .buildFrameworkFolder)
            .subfolder(named: pod.name)
            .subfolder(named: podChecksum(pod))
        else { return false }
        let localPodFrameworkFolder = try localFolder.createSubfolderIfNeeded(withName: .buildFrameworkFolder).createSubfolderIfNeeded(withName: pod.name)
        guard (try remotePodFrameworkFolder.contentChecksum()) != (try localPodFrameworkFolder.contentChecksum()) else { return false }
        try localPodFrameworkFolder.deleteAllContent()
        try remotePodFrameworkFolder.copyAllContent(to: localPodFrameworkFolder)
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
