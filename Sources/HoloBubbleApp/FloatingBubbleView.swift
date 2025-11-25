import SwiftUI
import AppKit

struct FloatingBubbleView: NSViewRepresentable {
    let text: String
    let color: Color
    let isVisible: Bool

    func makeNSView(context: Context) -> NSHostingView<BubbleBody> {
        let view = NSHostingView(rootView: BubbleBody(text: text, color: color, isVisible: isVisible))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        return view
    }

    func updateNSView(_ nsView: NSHostingView<BubbleBody>, context: Context) {
        nsView.rootView = BubbleBody(text: text, color: color, isVisible: isVisible)
    }

    struct BubbleBody: View {
        let text: String
        let color: Color
        let isVisible: Bool

        var body: some View {
            Group {
                if isVisible {
                    Text(text)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [color.opacity(0.9), color.opacity(0.55), color.opacity(0.9)]),
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(color.opacity(0.8), lineWidth: 1.5)
                                        .blur(radius: 0.5)
                                )
                                .shadow(color: color.opacity(0.35), radius: 18, x: 0, y: 10)
                                .shadow(color: .white.opacity(0.18), radius: 12, x: 0, y: -4)
                        )
                        .foregroundStyle(.white)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)
                        .transition(.opacity.combined(with: .scale))
                        .accessibilityHidden(true)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: isVisible)
        }
    }
}

final class FloatingBubbleWindow: NSPanel {
    init(contentView: NSView) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 10, height: 10),
                   styleMask: [.borderless],
                   backing: .buffered,
                   defer: false)

        level = .screenSaver
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        sharingType = .none // Attempt to stay out of screen recordings/screen sharing

        setFrame(NSRect(x: 0, y: 0, width: 400, height: 200), display: true)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
        self.contentView = contentView
    }
}
