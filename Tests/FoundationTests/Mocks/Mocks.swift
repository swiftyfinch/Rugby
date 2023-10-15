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
