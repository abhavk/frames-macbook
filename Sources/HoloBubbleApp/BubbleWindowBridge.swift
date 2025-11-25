import SwiftUI
import AppKit

struct BubbleWindowBridge: NSViewRepresentable {
    let text: String
    let color: Color
    let isVisible: Bool

    func makeNSView(context: Context) -> NSView {
        context.coordinator.updateWindow(text: text, color: color, isVisible: isVisible)
        return NSView(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.updateWindow(text: text, color: color, isVisible: isVisible)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        private var window: FloatingBubbleWindow?

        func updateWindow(text: String, color: Color, isVisible: Bool) {
            if window == nil {
                let hosting = NSHostingView(rootView: FloatingBubbleView.BubbleBody(text: text, color: color, isVisible: isVisible))
                window = FloatingBubbleWindow(contentView: hosting)
                window?.orderFrontRegardless()
            }

            if let hosting = window?.contentView as? NSHostingView<FloatingBubbleView.BubbleBody> {
                hosting.rootView = FloatingBubbleView.BubbleBody(text: text, color: color, isVisible: isVisible)
            }

            if isVisible {
                window?.orderFrontRegardless()
                window?.alphaValue = 1
            } else {
                window?.alphaValue = 0
            }
        }
    }
}
