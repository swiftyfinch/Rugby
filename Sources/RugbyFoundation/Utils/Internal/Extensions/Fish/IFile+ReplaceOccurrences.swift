import Fish

extension IFile {
    func replaceOccurrences(of target: String, with replacement: String = "") throws {
        var content = try read()
        content = content.replacingOccurrences(of: target, with: replacement)
        try write(content)
    }
}
