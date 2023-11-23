import RugbyFoundation

extension Vault {
    var standardOutput: IStandardOutput { StandardOutput() }
    var timerTaskFactory: ITimerTaskFactory { TimerTaskFactory() }
}
