//
//  LocalCache.swift
//
//
//  Created by mlch911 on 2023/3/10.
//

import ArgumentParser
import Files
import Foundation
import PathKit
import XcodeProj

struct LocalCache: ParsableCommand {
    struct Options: ParsableArguments {
        @Option(name: .shortAndLong, help: "Local Cache Location. Default: '~/.rugby_cache/'.") var location = "~/.rugby_cache/"
        @Flag(help: .beta("Check option. Use content checksums instead of modification date. Should be the same with your cache command option."))
        var useContentChecksums = false

        @Option(name: .shortAndLong, help: "Project Name. This will be used to group the Local cache. Should not set this if you don't know what you're doning. Automatically find name if nil") var projectName: String?
        @Option(name: .shortAndLong, help: "Main Project Location. Just for find project name. Automatically find location if nil") var mainProjectLocation: String?

        @Option(name: .shortAndLong, help: "Local Cache Total Size Limit. Remove oldest Cache when reached. \("10GB".yellow) or \("10000MB".yellow).")
        var sizeLimit: String?
        @Option(name: .shortAndLong, help: "Local Cache Date Limit. Remove oldest Cache when reached. \("10day".yellow) or \("1month".yellow).")
        var dateLimit: String?
    }

    @OptionGroup var options: Options
    @OptionGroup var flags: CommonFlags

    static var configuration = CommandConfiguration(
        abstract: "• Manage Local Cache.",
        subcommands: [LocalCacheSave.self, LocalCacheFetch.self, LocalCacheClean.self]
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: true) {
            try wrappedRun()
        }
    }
}

extension LocalCache: Command {
    var quiet: Bool {
        flags.quiet
    }

    var nonInteractive: Bool {
        flags.nonInteractive
    }

    mutating func run(logFile: Files.File) throws -> Metrics? {
        let progress = RugbyPrinter(title: "LocalCache", verbose: flags.verbose, quiet: flags.quiet, nonInteractive: flags.nonInteractive)
        progress.print("You should call subcommand.".red, level: 0)
        return nil
    }
}

extension LocalCache {
    struct Util {
        static func findProjectName(_ mainProjectLocation: String?) throws -> String {
            let mainProject: XcodeProj
            if let mainProjectLocation = mainProjectLocation {
                mainProject = try XcodeProj(pathString: File(path: mainProjectLocation).path)
            } else {
                let xcodeProjects = Folder.current.subfolders.filter { $0.extension == "xcodeproj" && $0.name != .podsProjectName }
                guard !xcodeProjects.isEmpty else { throw LocalCacheError.mainProjectNotFound }
                guard xcodeProjects.count == 1 else { throw LocalCacheError.foundMoreThanOneProject }
                mainProject = try XcodeProj(pathString: xcodeProjects.first!.path)
            }
            guard let projectName = try mainProject.pbxproj.rootProject()?.name else { throw LocalCacheError.projectNameNotFound }
            return projectName
        }

        static func checkProjectPatched() throws {
            let project = try ProjectProvider.shared.readProject(.podsProject)
            let projectPatched = project.pbxproj.main.contains(buildSettingsKey: .rugbyPatched)
            guard projectPatched else { throw LocalCacheError.notPatched }
        }
    }
}

extension LocalCache.Options {
    enum SizeLimit {
        case GB(Double)
        case MB(Double)
        case KB(Double)
        // swiftlint:disable:next identifier_name
        case B(Double)

        init?(_ str: String?) {
            guard let str = str?.lowercased() as? NSString else { return nil }
            if str.hasSuffix("gb") {
                guard let num = Double(str.substring(to: str.length - 2)) else { return nil }
                self = .GB(num)
            } else if str.hasSuffix("mb") {
                guard let num = Double(str.substring(to: str.length - 2)) else { return nil }
                self = .MB(num)
            }
            return nil
        }

        init(byte: Int) {
            let double = Double(byte)
            switch byte {
            case 0 ... 1023:
                self = .B(double)
            case 1024 ..< pow(1024, 2):
                self = .KB(double / 1024)
            case pow(1024, 2) ..< pow(1024, 3):
                self = .MB(double / Double(pow(1024, 2)))
            case pow(1024, 3)...:
                self = .GB(double / Double(pow(1024, 3)))
            default:
                self = .B(0)
            }
        }

        var byte: Int {
            switch self {
            case let .GB(val): return Int(val * Double(pow(1024, 3)))
            case let .MB(val): return Int(val * Double(pow(1024, 2)))
            case let .KB(val): return Int(val * 1024)
            case let .B(val): return Int(val)
            }
        }
    }

    enum DateLimit {
        case day(Double)
        case month(Double)

        init?(_ str: String?) {
            guard let str = str?.lowercased() as? NSString else { return nil }
            if str.hasSuffix("day") {
                guard let num = Double(str.substring(to: str.length - 3)) else { return nil }
                self = .day(num)
            } else if str.hasSuffix("month") {
                guard let num = Double(str.substring(to: str.length - 5)) else { return nil }
                self = .month(num)
            }
            return nil
        }

        var date: Date {
            switch self {
            case let .day(day):
                return Date(timeIntervalSinceNow: -day * 24 * 60 * 60)
            case let .month(month):
                return Date(timeIntervalSinceNow: -month * 30 * 24 * 60 * 60)
            }
        }
    }

    var sizeLimitStrategy: SizeLimit? { .init(sizeLimit) }
    var dateLimitStrategy: DateLimit? { .init(dateLimit) }
}

extension LocalCache.Options.SizeLimit: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.byte < rhs.byte
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.byte <= rhs.byte
    }

    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.byte >= rhs.byte
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.byte > rhs.byte
    }
}

private func pow(_ x: Int, _ y: Int) -> Int {
    Int(pow(Double(x), Double(y)))
}
