//
//  Mocks.swift
//  FoundationTests
//
//  Created by Vyacheslav Khorkov on 30.03.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Fish
@testable import RugbyFoundation

// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IShellExecutor {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation", "XcodeProj"]
extension IInternalTarget {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension ILogger {}

//// sourcery: AutoMockable, imports = ["Fish"]
// protocol IFilesManagerMock: IFilesManager {}
