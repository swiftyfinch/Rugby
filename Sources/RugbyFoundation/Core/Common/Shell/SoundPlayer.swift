// MARK: - Interface

/// The protocol describing a service to play sound notifications.
public protocol ISoundPlayer: AnyObject {
    /// Plays the bell notification.
    func playBell()
}

// MARK: - Implementation

final class SoundPlayer {
    private let shellExecutor: IShellExecutor

    init(shellExecutor: IShellExecutor) {
        self.shellExecutor = shellExecutor
    }
}

// MARK: - ISoundPlayer

extension SoundPlayer: ISoundPlayer {
    public func playBell() {
        try? shellExecutor.printShell("tput bel")
    }
}
