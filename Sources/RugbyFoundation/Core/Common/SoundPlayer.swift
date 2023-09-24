//
//  SoundPlayer.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 04.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

// MARK: - Interface

/// The protocol describing a service to play sound notifications.
public protocol ISoundPlayer {
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
