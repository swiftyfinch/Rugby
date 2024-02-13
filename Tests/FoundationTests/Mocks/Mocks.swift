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

//// sourcery: AutoMockable, imports = ["RugbyFoundation", "XcbeautifyLib"]
extension IBuildLogFormatter {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation", "XcodeProj"]
extension IInternalTarget {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ILogger {}

//// sourcery: AutoMockable, imports = ["Fish"]
// protocol IFilesManagerMock: IFilesManager {}

//// sourcery: AutoMockable, imports = ["Fish"]
extension IFolder {}

// sourcery: AutoMockable, imports = ["Fish"]
extension IFile {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IXcodeBuildExecutor {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension FoundationHasher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IFileContentHasher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IBuildPhaseHasher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ICocoaPodsScriptsHasher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IConfigurationsHasher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IProductHasher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IBuildRulesHasher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IXcodeEnvResolver {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ISwiftVersionProvider {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IArchitectureProvider {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IXcodeCLTVersionProvider {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IBinariesStorage {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IXcodeProject {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IBackupManager {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IRugbyXcodeProject {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IReachabilityChecker {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IURLSession {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IDecompressor {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IBuildTargetsManager {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ITargetsHasher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ICacheDownloader {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IMetricsLogger {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ILibrariesPatcher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ISupportFilesPatcher {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IFileContentEditor {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IProcessMonitor {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IXcodeBuild {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IUseBinariesManager {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IBinariesCleaner {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IEnvironmentCollector {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IEnvironment {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ITargetTreePainter {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ITestsStorage {}

// TODO: Needs to improve Sourcery template to generate mocks automatically w/o manual editing
