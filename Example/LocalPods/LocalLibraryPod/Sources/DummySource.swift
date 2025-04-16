import Foundation

public final class DummySource {
    public init() {}

    public func load() {
        print("mofucka")
    }
}

import Foundation
import SwiftUI

public extension View {

    func sizeReader(to binding: Binding<CGSize>) -> some View {
        onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { (newValue: CGSize) in
            binding.wrappedValue = newValue
        }
    }

    func heightReader(to binding: Binding<CGFloat>) -> some View {
        onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newValue in
            binding.wrappedValue = newValue
        }
    }

    func widthReader(to binding: Binding<CGFloat>) -> some View {
        onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            binding.wrappedValue = newValue
        }
    }

    func sizeListener(adding insets: EdgeInsets = .init()) -> some View {
        modifier(SizeListenerModifier(insets: insets))
    }
}

private struct SizeListenerModifier: ViewModifier {

    let insets: EdgeInsets

    @Environment(\.contentSizeListener) private var contentSizeListener
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        if let contentSizeListener {
            content
                .sizeReader(to: .init(get: { .zero }, set: { size = $0 }))
                .onChange(of: fullSize) {
                    contentSizeListener($0)
                }
        } else {
            content
        }
    }

    var fullSize: CGSize {
        CGSize(
            width: size.width + insets.leading + insets.trailing,
            height: size.height + insets.top + insets.bottom
        )
    }
}

public extension EnvironmentValues {

    @Entry var contentSizeListener: ContentSizeListener? = nil
}

public typealias ContentSizeListener = @MainActor @Sendable (CGSize) -> Void
