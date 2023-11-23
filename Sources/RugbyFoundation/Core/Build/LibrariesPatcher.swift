import Fish

// MARK: - Interface

protocol ILibrariesPatcher: AnyObject {
    func patch(_ targets: TargetsMap) async throws
}

// MARK: - Implementation

final class LibrariesPatcher: Loggable {
    let logger: ILogger

    init(logger: ILogger) {
        self.logger = logger
    }
}

extension LibrariesPatcher: ILibrariesPatcher {
    func patch(_ targets: TargetsMap) async throws {
        try await targets.values.concurrentForEach { target in
            guard target.product?.type == .staticLibrary,
                  target.buildPhases.contains(where: { $0.name == .copyXCFrameworks }) else { return }

            await self.log(
                "Overriding $PODS_XCFRAMEWORKS_BUILD_DIR variable in \(target.name)",
                level: .info,
                output: .file
            )
            try await target.xcconfigPaths.concurrentForEach { path in
                let xcconfig = try File.at(path)
                try xcconfig.replaceOccurrences(
                    of: .defaultPodsXCFrameworksBuildDir,
                    with: .configPodsXCFrameworksBuildDir
                )
                target.updateConfigurations()
            }
        }
    }
}

private extension String {
    static let copyXCFrameworks = "[CP] Copy XCFrameworks"
    static let defaultPodsXCFrameworksBuildDir =
        "PODS_XCFRAMEWORKS_BUILD_DIR = $(PODS_CONFIGURATION_BUILD_DIR)/XCFrameworkIntermediates"
    static let configPodsXCFrameworksBuildDir =
        "PODS_XCFRAMEWORKS_BUILD_DIR = ${PODS_CONFIGURATION_BUILD_DIR}/${PRODUCT_NAME}"
}
