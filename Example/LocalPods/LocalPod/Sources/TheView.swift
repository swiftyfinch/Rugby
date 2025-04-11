import LocalLibraryPod
import SwiftUI

public struct SomeSizeReaderView: View {

    @State var size: CGSize = .zero

    public var body: some View {
        HStack {
            Text("Hi")
            Text("Hey")
        }
        .sizeReader(to: $size)
    }
}

#Preview {
    SomeSizeReaderView()
}
