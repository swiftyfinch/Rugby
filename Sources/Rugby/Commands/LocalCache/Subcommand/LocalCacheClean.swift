//
//  LocalCacheClean.swift
//  
//
//  Created by mlch911 on 2023/3/17.
//

import ArgumentParser
import Files
import Foundation
import XcodeProj
import PathKit

extension LocalCache {
    struct LocalCacheClean: ParsableCommand, Command {
        @OptionGroup var options: Options
        @OptionGroup var flags: CommonFlags
        @Flag(name: .shortAndLong, help: "Clean All Local Cache.") var all = false
        
        static var configuration = CommandConfiguration(
            abstract: "• Clean Local Cache."
        )
        
        var quiet: Bool {
            flags.quiet
        }
        
        var nonInteractive: Bool {
            flags.nonInteractive
        }
        
        mutating func run(logFile: Files.File) throws -> Metrics? {
            let progress = RugbyPrinter(title: "LocalCacheClean", verbose: flags.verbose, quiet: flags.quiet, nonInteractive: flags.nonInteractive)
            try LocalCacheCleanStep(options: options, progress: progress, cleanAll: all).run()
            return nil
        }
    }
}

struct LocalCacheCleanStep: Step {
    let progress: Printer
    let options: LocalCache.Options
    let cleanAll: Bool
    
    init(options: LocalCache.Options, progress: Printer, cleanAll: Bool) {
        self.progress = progress
        self.options = options
        self.cleanAll = cleanAll
    }
    
    func run(_ input: Void) throws {
        let remoteFolder = try Folder(path: options.location)
        allPodFolders = try allFolders(options.location)
        
        if cleanAll {
            try progress.spinner("Clean All Local Cache.") {
                try remoteFolder.deleteAllContent()
            }
            return
        }
        
        if let sizeLimit = options.sizeLimitStrategy {
            try progress.spinner("Check Size") {
                while LocalCache.Options.SizeLimit(byte: remoteFolder.size() ?? 0) > sizeLimit, let folder = oldestFolder() {
                    try delete(folder, "Reach Size Limit")
                }
            }
        }
        if let dateLimit = options.dateLimitStrategy {
            try progress.spinner("Check Date") {
                while let folder = oldestFolder(), let date = folder.modificationDate, date < dateLimit.date {
                    try delete(folder, "Reach Date Limit")
                }
            }
        }
        done()
    }
    
    private func oldestFolder() -> Folder? {
        allPodFolders.sorted(by: { $0.modificationDate! > $1.modificationDate! }).last
    }
    
    private func delete(_ folder: Folder, _ desc: String) throws {
        let remoteFolder = try Folder(path: options.location)
        let name = folder.name
        try allPodFolders
            .filter { $0.name == name }
            .forEach {
                progress.print("[\(desc)] Deleting oldest Pod: \($0.path(relativeTo: remoteFolder))")
                try $0.delete()
            }
        allPodFolders = allPodFolders.filter { $0.name != name }
    }
}

private var allPodFolders = [Folder]()

private func allFolders(_ location: String) throws -> [Folder] {
    let remoteFolder = try Folder(path: location)
    var allFolders = remoteFolder.subfolders
        .map(\.subfolders)
        .flatMap { $0 }
        .map(\.subfolders)
        .flatMap { $0 }
        .filter { $0.name != .buildFrameworkFolder }
        .map(\.subfolders)
        .flatMap { $0 }
    assert(allFolders.filter({ $0.path.contains(String.buildFrameworkFolder) }).isEmpty)
    
    let allFrameworkFolders = remoteFolder.subfolders
        .map(\.subfolders)
        .flatMap { $0 }
        .map(\.subfolders)
        .flatMap { $0 }
        .filter { $0.name == .buildFrameworkFolder }
        .map(\.subfolders)
        .flatMap { $0 }
        .map(\.subfolders)
        .flatMap { $0 }
    assert(allFrameworkFolders.filter({ !$0.path.contains(String.buildFrameworkFolder) }).isEmpty)
    
    allFolders.append(contentsOf: allFrameworkFolders)
    return allFolders
}
