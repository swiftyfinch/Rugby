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
extension ISwiftVersionProvider {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IArchitectureProvider {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IXcodeCLTVersionProvider {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IBinariesStorage {}
