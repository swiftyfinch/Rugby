import XcodeProj

struct Scheme {
    let xcscheme: XCScheme
    let path: String

    var name: String { xcscheme.name }

    init(path: String) throws {
        xcscheme = try XCScheme(path: .init(path))
        self.path = path
    }
}

// MARK: - Hashable

extension Scheme: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}
