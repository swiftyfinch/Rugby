//
//  TimerTask.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 19.10.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

final class TimerTask {
    private let interval: TimeInterval
    private let timer: Timer

    init(interval: TimeInterval, task: @escaping () -> Void) {
        self.interval = interval
        self.timer = Timer(timeInterval: interval, repeats: true) { _ in
            task()
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    func cancel() {
        timer.invalidate()
    }

    deinit {
        cancel()
    }
}
