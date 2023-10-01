import Foundation
import Yams

// MARK: - Interface

enum TargetsHasherError: LocalizedError {
    case emptyConfigurations(target: String)

    var errorDescription: String? {
        let output: String
        switch self {
        case let .emptyConfigurations(target):
            output = #"Couldn't find any configuration in target "\#(target)"."#
        }
        return output
    }
}

// MARK: - Implementation

final class TargetsHasher {
    private typealias Error = TargetsHasherError
    private let foundationHasher: FoundationHasher
    private let swiftVersionProvider: ISwiftVersionProvider
    private let buildPhaseHasher: BuildPhaseHasher
    private let cocoaPodsScriptsHasher: CocoaPodsScriptsHasher
    private let configurationsHasher: ConfigurationsHasher
    private let productHasher: ProductHasher
    private let buildRulesHasher: BuildRulesHasher

    init(foundationHasher: FoundationHasher,
         swiftVersionProvider: ISwiftVersionProvider,
         buildPhaseHasher: BuildPhaseHasher,
         cocoaPodsScriptsHasher: CocoaPodsScriptsHasher,
         configurationsHasher: ConfigurationsHasher,
         productHasher: ProductHasher,
         buildRulesHasher: BuildRulesHasher) {
        self.foundationHasher = foundationHasher
        self.swiftVersionProvider = swiftVersionProvider
        self.buildPhaseHasher = buildPhaseHasher
        self.cocoaPodsScriptsHasher = cocoaPodsScriptsHasher
        self.configurationsHasher = configurationsHasher
        self.productHasher = productHasher
        self.buildRulesHasher = buildRulesHasher
    }

    func hash(_ targets: Set<Target>, xcargs: [String], rehash: Bool = false) async throws {
        targets.modifyIf(rehash) { resetHash($0) }

        try await targets.union(targets.flatMap(\.dependencies)).concurrentForEach { target in
            guard target.targetHashContext == nil else { return }
            target.targetHashContext = try await self.targetHashContext(target, xcargs: xcargs)
        }

        for target in targets {
            try await hash(target)
        }
    }

    // MARK: - Private

    private func hash(_ target: Target) async throws {
        guard target.hash == nil else { return }

        var dependencyHashes: [String: String?] = [:]
        for dependency in target.dependencies {
            try await hash(dependency)
            dependencyHashes.updateValue(dependency.hash, forKey: dependency.name)
        }

        let hashContext = try await hashContext(target, dependencyHashes: dependencyHashes)
        target.hash = foundationHasher.hash(hashContext)
        target.hashContext = hashContext
    }

    private func hashContext(_ target: Target, dependencyHashes: [String: String?]) async throws -> String {
        guard var targetHashContext = target.targetHashContext else { fatalError("Can't find target hash context.") }
        targetHashContext["dependencies"] = dependencyHashes
        return try Yams.dump(object: targetHashContext, width: -1, sortKeys: true)
    }

    private func targetHashContext(_ target: Target, xcargs: [String]) async throws -> [String: Any] {
        try await [
            "name": target.name,
            "swift_version": swiftVersionProvider.swiftVersion(),
            "buildOptions": [
                "xcargs": xcargs.sorted()
            ],
            "buildPhases": buildPhaseHasher.hashContext(target: target),
            "product": target.product.map(productHasher.hashContext) as Any,
            "configurations": configurationsHasher.hashContext(target),
            "cocoaPodsScripts": cocoaPodsScriptsHasher.hashContext(target),
            "buildRules": buildRulesHasher.hashContext(target.buildRules)
        ]
    }

    private func resetHash(_ targets: Set<Target>) {
        targets.union(targets.flatMap(\.dependencies)).forEach { target in
            target.hash = nil
            target.hashContext = nil
            target.targetHashContext = nil
        }
    }
}

// MARK: - Context Properties

extension Target {
    var hash: String? {
        get { context[String.hashKey] as? String }
        set { context[String.hashKey] = newValue }
    }

    var hashContext: String? {
        get { context[String.hashContextKey] as? String }
        set { context[String.hashContextKey] = newValue }
    }

    var targetHashContext: [String: Any]? {
        get { context[String.targetHashContextKey] as? [String: Any] }
        set { context[String.targetHashContextKey] = newValue }
    }
}

private extension String {
    static let hashKey = "HASH"
    static let hashContextKey = "HASH_CONTEXT"
    static let targetHashContextKey = "TARGET_HASH_CONTEXT"
}
