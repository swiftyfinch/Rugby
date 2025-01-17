import Foundation

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

enum ReplacementBoundary {
    static let prefix = #"(?<=(\"|'|\s))"#
    static let suffix = #"(?=(\"|'|\s|/))"#
}

protocol ISupportFilesPatcher: AnyObject {
    func prepareReplacements(forTarget target: IInternalTarget) throws -> [FileReplacement]
}

final class SupportFilesPatcher {
    private typealias Replacement = (lookup: String, replacement: String)

    // swiftlint:disable identifier_name
    private let PREFIX_BOUNDARY = ReplacementBoundary.prefix
    private let SUFFIX_BOUNDARY = ReplacementBoundary.suffix
    private let BUILT_PRODUCTS_DIR = "${BUILT_PRODUCTS_DIR}/"
    private let PODS_CONFIGURATION_BUILD_DIR = "${PODS_CONFIGURATION_BUILD_DIR}/"
    private let PODS_XCFRAMEWORKS_BUILD_DIR = "${PODS_XCFRAMEWORKS_BUILD_DIR}/"
    private let HEADERS = "Headers"
    // swiftlint:enable identifier_name

    private func prepareXCConfigReplacements(target: IInternalTarget) throws -> [FileReplacement] {
        let replacementsPairs: [Replacement] = target.binaryProducts.reduce(into: []) { result, product in
            guard product.type != .bundle, let binaryFolderPath = product.binaryPath else { return }
            result.append(("\(PODS_CONFIGURATION_BUILD_DIR)\(product.nameWithParent)/\(HEADERS)",
                           replacement: "\(binaryFolderPath)/\(product.fileName)/\(HEADERS)"))

            guard let parentFolderName = product.parentFolderName else { return }
            result.append(("\(PODS_CONFIGURATION_BUILD_DIR)\(parentFolderName)",
                           replacement: binaryFolderPath))

            guard let moduleName = product.moduleName else { return }
            let moduleMap = "\(moduleName).modulemap"
            result.append(("\(PODS_CONFIGURATION_BUILD_DIR)\(parentFolderName)/\(moduleMap)",
                           replacement: "\(binaryFolderPath)/\(moduleMap)"))

            if product.type == .staticLibrary {
                result.append((
                    "\(PODS_XCFRAMEWORKS_BUILD_DIR)\(product.name)/\(HEADERS)",
                    replacement: "\(binaryFolderPath)/\(product.name)/\(HEADERS)"
                ))
                result.append((
                    "\(PODS_XCFRAMEWORKS_BUILD_DIR)\(product.name)",
                    replacement: "\(binaryFolderPath)/\(product.name)"
                ))
            }
        }

        let replacements = buildMap(from: replacementsPairs)

        let regex = try buildRegexPattern(from: replacementsPairs,
                                          prefix: PREFIX_BOUNDARY,
                                          suffix: SUFFIX_BOUNDARY).regex()

        return target.xcconfigPaths.compactMap {
            FileReplacement(replacements: replacements, filePath: $0, regex: regex)
        }
    }

    private func prepareFrameworksReplacements(target: IInternalTarget) throws -> FileReplacement? {
        guard target.isTests || target.isPodsUmbrella || target.isApplication,
              let filePath = target.frameworksScriptPath else { return nil }

        let replacementsPairs: [Replacement] = target.binaryProducts.compactMap { product in
            guard product.type != .bundle, let binaryFolderPath = product.binaryPath else { return nil }
            return (product.nameWithParent, replacement: "\(binaryFolderPath)/\(product.fileName)")
        }

        let replacements = buildMap(from: replacementsPairs,
                                    modifyKey: { "\(BUILT_PRODUCTS_DIR)\($0)" })

        let regex = try buildRegexPattern(from: replacementsPairs,
                                          prefix: "\(PREFIX_BOUNDARY)\(BUILT_PRODUCTS_DIR.escapedPattern)",
                                          suffix: SUFFIX_BOUNDARY).regex()

        return FileReplacement(replacements: replacements, filePath: filePath, regex: regex)
    }

    private func prepareResourcesReplacements(target: IInternalTarget) throws -> FileReplacement? {
        guard target.isTests || target.isPodsUmbrella || target.isApplication,
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
                                    modifyKey: { "\(PODS_CONFIGURATION_BUILD_DIR)\($0)" })
        replacements = buildMap(from: frameworksReplacementsPairs,
                                initial: replacements,
                                modifyKey: { "\(BUILT_PRODUCTS_DIR)\($0)" })

        let bundlesRegexPattern = buildRegexPattern(
            from: bundlesReplacementsPairs,
            prefix: "\(PREFIX_BOUNDARY)\(PODS_CONFIGURATION_BUILD_DIR.escapedPattern)",
            suffix: SUFFIX_BOUNDARY
        )

        let frameworksRegexPattern = buildRegexPattern(from: frameworksReplacementsPairs,
                                                       prefix: BUILT_PRODUCTS_DIR.escapedPattern)
        let regex = try "(\(bundlesRegexPattern)|\(frameworksRegexPattern))".regex()

        return FileReplacement(replacements: replacements, filePath: filePath, regex: regex)
    }

    // MARK: - Utils

    private func buildMap(from replacements: [Replacement],
                          initial: [String: String] = [:],
                          modifyKey: (String) -> String = { $0 },
                          modifyValue: (String) -> String = { $0 }) -> [String: String] {
        replacements.reduce(into: initial) { result, replacement in
            let (lookup, replacement) = replacement
            result[modifyKey(lookup)] = modifyValue(replacement)
        }
    }

    private func buildRegexPattern(from replacements: [Replacement],
                                   prefix: String = "",
                                   suffix: String = "") -> String {
        let replacements = replacements.lazy.map(\.lookup).map(NSRegularExpression.escapedPattern(for:))
        let replacementsJoined = replacements.joined(separator: "|")
        return "\(prefix)(\(replacementsJoined))\(suffix)"
    }
}

extension SupportFilesPatcher: ISupportFilesPatcher {
    func prepareReplacements(forTarget target: IInternalTarget) throws -> [FileReplacement] {
        var replacements = try prepareXCConfigReplacements(target: target)
        if let frameworksReplacements = try prepareFrameworksReplacements(target: target) {
            replacements.append(frameworksReplacements)
        }
        if let resourcesReplacements = try prepareResourcesReplacements(target: target) {
            replacements.append(resourcesReplacements)
        }
        return replacements
    }
}
