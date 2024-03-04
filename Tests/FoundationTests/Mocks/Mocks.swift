//
//  Mocks.swift
//  FoundationTests
//
//  Created by Vyacheslav Khorkov on 30.03.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Fish
@testable import RugbyFoundation
import SwiftShell

// sourcery: AutoMockable, imports = ["RugbyFoundation", "SwiftShell"]
extension IShellExecutor {}

// sourcery: AutoMockable, imports = ["SwiftShell"]
extension ReadableStream {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"], imports = ["XcbeautifyLib"]
extension IBuildLogFormatter {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"], imports = ["XcodeProj"]
extension IInternalTarget {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ILogger {}

// sourcery: AutoMockable, imports = ["Fish"]
// protocol IFilesManagerMock: IFilesManager {}

// sourcery: AutoMockable, imports = ["Fish"]
extension IFolder {}

// sourcery: AutoMockable, imports = ["Fish"]
extension IFile {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IXcodeBuildExecutor {}

//// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension FoundationHasher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IFileContentHasher {}

//// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IBuildPhaseHasher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ICocoaPodsScriptsHasher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IConfigurationsHasher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IProductHasher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IBuildRulesHasher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IXcodeEnvResolver {}

//// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ISwiftVersionProvider {}

// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IArchitectureProvider {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IXcodeCLTVersionProvider {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IBinariesStorage {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IXcodeProject {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IBackupManager {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IRugbyXcodeProject {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IReachabilityChecker {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IURLSession {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IDecompressor {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IBuildTargetsManager {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ITargetsHasher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ICacheDownloader {}

// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IMetricsLogger {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ILibrariesPatcher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ISupportFilesPatcher {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IFileContentEditor {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"], imports = ["SwiftShell"]
extension IProcessMonitor {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IXcodeBuild {}

// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IUseBinariesManager {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IBinariesCleaner {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IEnvironmentCollector {}

// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IEnvironment {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ITargetTreePainter {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ITestsStorage {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IInternalXcodeProject {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IInternalBuildManager {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IGit {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IInternalUseBinariesManager {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ITestplanEditor {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension IInternalTestImpactManager {}

// sourcery: AutoMockable, testableImports = ["RugbyFoundation"]
extension ISimCTL {}

// TODO: Needs to improve Sourcery template to generate mocks automatically w/o manual editing
