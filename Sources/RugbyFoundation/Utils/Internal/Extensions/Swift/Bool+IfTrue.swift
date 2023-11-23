extension Bool {
    func ifTrue(do job: () throws -> Void) rethrows {
        guard self else { return }
        try job()
    }

    func ifFalse(do job: () throws -> Void) rethrows {
        guard !self else { return }
        try job()
    }
}
