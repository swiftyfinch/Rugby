import Fish
@testable import Rugby
import RugbyFoundation

// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension Printer {}

//// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IProgressPrinter {}

// sourcery: AutoMockable, imports = ["RugbyFoundation"]
extension IMetricsLogger {}

// sourcery: AutoMockable, imports = ["Fish"]
extension IFile {}

//// sourcery: AutoMockable, imports = ["Rugby"]
extension IStandardOutput {}

//// sourcery: AutoMockable, imports = ["Rugby"]
extension ITimerTaskFactory {}

//// sourcery: AutoMockable, imports = ["Rugby"]
extension ITimerTask {}

//// sourcery: AutoMockable, imports = ["Rugby"]
extension IClock {}
