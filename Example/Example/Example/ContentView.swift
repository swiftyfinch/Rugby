import Alamofire
import KeyboardLayoutGuide
import Kingfisher
import LocalPod
import Moya
import SnapKit
import SwiftUI

struct ContentView: View {
    private let dummy = DummySource()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            // Just for testing
            dummy.load()
        }
    }
}
