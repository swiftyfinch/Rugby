import Fish
import RugbyFoundation

extension Router {
    var podsProjectRelativePath: String {
        Folder.current.subpath("Pods", "Pods.xcodeproj")
            .relativePath(to: Folder.current.path)
    }

    var plansRelativePath: String { ".rugby/plans.yml" }
}
