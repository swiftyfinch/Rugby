//
//  SupportFilesPatcher.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 27.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

final class SupportFilesPatcher {
    private typealias Replacement = (lookup: String, replacement: String)

    // swiftlint:disable identifier_name
    private let QUOTE = "\""
    private let BUILT_PRODUCTS_DIR = "${BUILT_PRODUCTS_DIR}/"
    private let PODS_CONFIGURATION_BUILD_DIR = "${PODS_CONFIGURATION_BUILD_DIR}/"
    private let HEADERS = "Headers"
    // swiftlint:enable identifier_name

    struct FileReplacement {
        let replacements: [String: String]
        let filePath: String
        let regex: NSRegularExpression

        init?(replacements: [String: String], filePath: String, regex: NSRegularExpression) {
            guard replacements.isNotEmpty else { return nil }
            self.replacements = replacements
            self.filePath = filePath
            self.regex = regex
        }
    }

    func prepareReplacements(forTarget target: Target) throws -> [FileReplacement] {
        var replacements = try prepareXCConfigReplacements(target: target)
        if let frameworksReplacements = try prepareFrameworksReplacements(target: target) {
            replacements.append(frameworksReplacements)
        }
        if let resourcesReplacements = try prepareResourcesReplacements(target: target) {
            replacements.append(resourcesReplacements)
        }
        return replacements
    }

    private func prepareXCConfigReplacements(target: Target) throws -> [FileReplacement] {
        let replacementsPairs: [Replacement] = target.binaryProducts.reduce(into: []) { result, product in
            guard product.type != .bundle, let binaryFolderPath = product.binaryPath else { return }
            if let parentFolderName = product.parentFolderName {
                result.append((parentFolderName, replacement: binaryFolderPath))
            }
            result.append(("\(product.nameWithParent)/\(HEADERS)",
                           replacement: "\(binaryFolderPath)/\(product.fileName)/\(HEADERS)"))
        }

        let replacements = buildMap(from: replacementsPairs,
                                    modifyKey: { "\(PODS_CONFIGURATION_BUILD_DIR)\($0)".quoted },
                                    modifyValue: \.quoted)

        let regex = try buildRegexPattern(from: replacementsPairs,
                                          prefix: "\(QUOTE)\(PODS_CONFIGURATION_BUILD_DIR)",
                                          suffix: QUOTE).regex()

        return target.xcconfigPaths.compactMap {
            FileReplacement(replacements: replacements, filePath: $0, regex: regex)
        }
    }

    private func prepareFrameworksReplacements(target: Target) throws -> FileReplacement? {
        guard target.isTests || target.isPodsUmbrella,
              let filePath = target.frameworksScriptPath else { return nil }

        let replacementsPairs: [Replacement] = target.binaryProducts.compactMap { product in
            guard product.type != .bundle, let binaryFolderPath = product.binaryPath else { return nil }
            return (product.nameWithParent, replacement: "\(binaryFolderPath)/\(product.fileName)")
        }

        let replacements = buildMap(from: replacementsPairs,
                                    modifyKey: { "\(BUILT_PRODUCTS_DIR)\($0)".quoted },
                                    modifyValue: \.quoted)

        let regex = try buildRegexPattern(from: replacementsPairs,
                                          prefix: "\(QUOTE)\(BUILT_PRODUCTS_DIR)",
                                          suffix: QUOTE).regex()

        return FileReplacement(replacements: replacements, filePath: filePath, regex: regex)
    }

    private func prepareResourcesReplacements(target: Target) throws -> FileReplacement? {
        guard target.isTests || target.isPodsUmbrella,
              let filePath = target.resourcesScriptPath else { return nil }

        let bundlesReplacementsPairs: [Replacement] = target.binaryProducts.compactMap { product in
            guard product.type == .bundle, let binaryFolderPath = product.binaryPath else { return nil }
            return (product.nameWithParent, replacement: "\(binaryFolderPath)/\(product.fileName)")
        }
        let frameworksReplacementsPairs: [Replacement] = target.binaryProducts.compactMap { product in
            guard product.type != .bundle, let binaryFolderPath = product.binaryPath else { return nil }
            return ("\(product.nameWithParent)/", replacement: "\(binaryFolderPath)/\(product.fileName)/")
        }

        var replacements = buildMap(from: bundlesReplacementsPairs,
                                    modifyKey: { "\(PODS_CONFIGURATION_BUILD_DIR)\($0)".quoted },
                                    modifyValue: \.quoted)
        replacements = buildMap(from: frameworksReplacementsPairs,
                                initial: replacements,
                                modifyKey: { "\(BUILT_PRODUCTS_DIR)\($0)" })

        let bundlesRegexPattern = buildRegexPattern(from: bundlesReplacementsPairs,
                                                    prefix: "\(QUOTE)\(PODS_CONFIGURATION_BUILD_DIR)",
                                                    suffix: QUOTE)
        let frameworksRegexPattern = buildRegexPattern(from: frameworksReplacementsPairs,
                                                       prefix: BUILT_PRODUCTS_DIR)
        let regex = try "(\(bundlesRegexPattern)|\(frameworksRegexPattern))".regex()

        return FileReplacement(replacements: replacements, filePath: filePath, regex: regex)
    }

    // MARK: - Utils

    private func buildMap(from replacements: [Replacement],
                          initial: [String: String] = [:],
                          modifyKey: (String) -> String,
                          modifyValue: (String) -> String = { $0 }) -> [String: String] {
        replacements.reduce(into: initial) { result, replacement in
            let (lookup, replacement) = replacement
            result[modifyKey(lookup)] = modifyValue(replacement)
        }
    }

    private func buildRegexPattern(from replacements: [Replacement],
                                   prefix: String,
                                   suffix: String = "") -> String {
        let prefix = NSRegularExpression.escapedPattern(for: prefix)
        let replacements = replacements.lazy.map(\.lookup).map(NSRegularExpression.escapedPattern(for:))
        let replacementsJoined = replacements.joined(separator: "|")
        return "\(prefix)(\(replacementsJoined))\(suffix)"
    }
}
