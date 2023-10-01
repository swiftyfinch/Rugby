import Alamofire
import Foundation

public final class DummySource {
    public init() {}

    public func load() {
        AF.request("https://httpbin.org/get").response { response in
            debugPrint(response)
        }
    }
}
