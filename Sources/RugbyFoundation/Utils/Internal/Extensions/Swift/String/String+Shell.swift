extension String {
    var shellFriendly: String {
        replacingOccurrences(of: " ", with: "\\ ")
    }
}
