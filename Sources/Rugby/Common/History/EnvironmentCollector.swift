//
//  EnvironmentCollector.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 03.06.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

struct EnvironmentCollector {
    func write(to logFile: File) {
        let printer = FilePrinter(file: logFile)
        let environment = [
            "Rugby version: " + Rugby.configuration.version,
            "Command: rugby " + CommandLine.arguments.dropFirst().joined(separator: " "),
            getXcodeVersion(),
            getSwiftVersion(),
            getCPU(),
            getProject(),
            getGitBranch()
        ]
        environment.forEach { printer.print("* " + $0) }
        printer.print(.separator)
    }

    private func getXcodeVersion() -> String {
        let output = try? shell("xcodebuild -version")
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .joined(separator: " / ")
        return output ?? "Xcode: " + .unknown
    }

    private func getSwiftVersion() -> String {
        let version = try? shell("swift --version").components(separatedBy: .newlines).first
        return version ?? "Swift: " + .unknown
    }

    private func getCPU() -> String {
        let cpu = (try? shell("sysctl -n machdep.cpu.brand_string")) ?? .unknown
        return "CPU: " + cpu
    }

    private func getProject() -> String {
        let project = Folder.current.subfolders
            .filter { $0.url.pathExtension == "xcodeproj" || $0.url.pathExtension == "xcworkspace" }
            .map(\.nameExcludingExtension).first
        return "Project: " + (project ?? .unknown)
    }

    private func getGitBranch() -> String {
        let branch = try? shell("git branch --show-current")
        return "Git branch: " + (branch ?? .unknown)
    }
}

private extension String {
    static let unknown = "Unknown"
}
